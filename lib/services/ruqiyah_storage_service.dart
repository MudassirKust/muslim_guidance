import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuqiyahStorageService {
  static final RuqiyahStorageService _instance =
      RuqiyahStorageService._internal();
  factory RuqiyahStorageService() => _instance;
  RuqiyahStorageService._internal();

  final Dio _dio = Dio();

  // Track ongoing downloads: Map<audioId, progressObservable>
  final Map<int, RxDouble> _ongoingDownloads = {};

  // Check if a download is in progress for a specific audio
  bool isDownloadInProgress(int audioId) {
    return _ongoingDownloads.containsKey(audioId);
  }

  // Get progress observable for ongoing download
  RxDouble? getDownloadProgress(int audioId) {
    return _ongoingDownloads[audioId];
  }

  // Get the directory for storing Ruqiyah audio files
  Future<Directory> _getRuqiyahDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final ruqiyahDir = Directory('${appDir.path}/ruqiyah');
    if (!await ruqiyahDir.exists()) {
      await ruqiyahDir.create(recursive: true);
    }
    return ruqiyahDir;
  }

  // Get file extension from URL
  String _getFileExtension(String url) {
    if (url.contains('.m4a')) return 'm4a';
    if (url.contains('.mp3')) return 'mp3';
    return 'mp3'; // default
  }

  // Check if a Ruqiyah audio is downloaded AND verify integrity
  Future<bool> isRuqiyahDownloaded(int audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMarkedDownloaded =
          prefs.getBool('ruqiyah_${audioId}_downloaded') ?? false;

      if (!isMarkedDownloaded) return false;

      // Verify the file actually exists
      final dir = await _getRuqiyahDirectory();
      final audioUrl = prefs.getString('ruqiyah_${audioId}_url') ?? '';
      final extension = _getFileExtension(audioUrl);
      final audioFile = File('${dir.path}/ruqiyah_audio_$audioId.$extension');

      if (!await audioFile.exists()) {
        debugPrint(
            'Ruqiyah audio $audioId marked as downloaded but file missing. Cleaning up.');
        await _cleanupIncompleteDownload(audioId);
        return false;
      }

      // Verify file is not corrupted (has reasonable size)
      final fileSize = await audioFile.length();
      if (fileSize < 100 * 1024) {
        // Minimum 100KB
        debugPrint(
            'Ruqiyah audio $audioId corrupted (size: $fileSize). Cleaning up.');
        await _cleanupIncompleteDownload(audioId);
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error verifying Ruqiyah audio download: $e');
      return false;
    }
  }

  // Clean up incomplete or corrupted downloads
  Future<void> _cleanupIncompleteDownload(int audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dir = await _getRuqiyahDirectory();

      // Try both extensions
      final audioFileM4a = File('${dir.path}/ruqiyah_audio_$audioId.m4a');
      final audioFileMp3 = File('${dir.path}/ruqiyah_audio_$audioId.mp3');

      if (await audioFileM4a.exists()) {
        await audioFileM4a.delete();
      }
      if (await audioFileMp3.exists()) {
        await audioFileMp3.delete();
      }

      await prefs.remove('ruqiyah_${audioId}_downloaded');
      await prefs.remove('ruqiyah_${audioId}_url');

      debugPrint('Cleaned up incomplete download for Ruqiyah audio $audioId');
    } catch (e) {
      debugPrint('Error cleaning up incomplete download: $e');
    }
  }

  // Get local audio file path (returns null if not downloaded)
  Future<String?> getLocalAudioPath(int audioId) async {
    try {
      final isDownloaded = await isRuqiyahDownloaded(audioId);
      if (!isDownloaded) return null;

      final prefs = await SharedPreferences.getInstance();
      final audioUrl = prefs.getString('ruqiyah_${audioId}_url') ?? '';
      final extension = _getFileExtension(audioUrl);

      final dir = await _getRuqiyahDirectory();
      final audioPath = '${dir.path}/ruqiyah_audio_$audioId.$extension';

      final audioFile = File(audioPath);
      if (await audioFile.exists()) {
        return audioPath;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting local audio path: $e');
      return null;
    }
  }

  // Download a Ruqiyah audio file
  Future<void> downloadRuqiyahAudio({
    required int audioId,
    required String audioUrl,
    required Function(double) onProgress,
    CancelToken? cancelToken,
  }) async {
    // Register this download in ongoing downloads map
    final progressObservable = RxDouble(0.0);
    _ongoingDownloads[audioId] = progressObservable;

    try {
      final dir = await _getRuqiyahDirectory();
      final extension = _getFileExtension(audioUrl);
      final audioPath = '${dir.path}/ruqiyah_audio_$audioId.$extension';

      // Check if file already exists and is valid (for resume support)
      final audioFile = File(audioPath);
      if (await audioFile.exists()) {
        final fileSize = await audioFile.length();
        if (fileSize > 100 * 1024) {
          // File is valid (>100KB)
          // Already downloaded
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('ruqiyah_${audioId}_downloaded', true);
          await prefs.setString('ruqiyah_${audioId}_url', audioUrl);
          onProgress(1.0);
          progressObservable.value = 1.0;
          return;
        } else {
          // File is corrupted, delete and re-download
          debugPrint(
              'Deleting corrupted file: $audioPath (size: $fileSize bytes)');
          await audioFile.delete();
        }
      }

      // Configure Dio for large file downloads
      _dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(seconds: 30),
      );

      // Download with retry
      bool downloaded = false;
      int retries = 3;

      while (!downloaded && retries > 0) {
        try {
          await _dio.download(
            audioUrl,
            audioPath,
            cancelToken: cancelToken,
            deleteOnError: true,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = received / total;
                onProgress(progress);
                progressObservable.value = progress;
              }
            },
          );
          downloaded = true;
        } catch (e) {
          retries--;
          if (retries == 0) {
            debugPrint('Failed to download after 3 retries: $e');
            rethrow;
          }
          debugPrint('Download failed, retrying... ($retries retries left)');
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      // Verify the file after download
      if (await audioFile.exists()) {
        final fileSize = await audioFile.length();
        if (fileSize < 100 * 1024) {
          throw Exception(
              'Downloaded file is too small (corrupted): $fileSize bytes');
        }
      } else {
        throw Exception('Audio file missing after download');
      }

      // Mark as downloaded only after verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ruqiyah_${audioId}_downloaded', true);
      await prefs.setString('ruqiyah_${audioId}_url', audioUrl);

      onProgress(1.0);
      progressObservable.value = 1.0;

      debugPrint('Successfully downloaded Ruqiyah audio $audioId');
    } catch (e) {
      debugPrint('Error downloading Ruqiyah audio: $e');
      rethrow;
    } finally {
      // Unregister from ongoing downloads
      _ongoingDownloads.remove(audioId);
    }
  }

  // Delete a downloaded Ruqiyah audio
  Future<void> deleteRuqiyahAudio(int audioId) async {
    try {
      final dir = await _getRuqiyahDirectory();

      // Try both extensions
      final audioFileM4a = File('${dir.path}/ruqiyah_audio_$audioId.m4a');
      final audioFileMp3 = File('${dir.path}/ruqiyah_audio_$audioId.mp3');

      if (await audioFileM4a.exists()) {
        await audioFileM4a.delete();
      }
      if (await audioFileMp3.exists()) {
        await audioFileMp3.delete();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ruqiyah_${audioId}_downloaded');
      await prefs.remove('ruqiyah_${audioId}_url');

      debugPrint('Deleted Ruqiyah audio $audioId');
    } catch (e) {
      debugPrint('Error deleting Ruqiyah audio: $e');
    }
  }

  // Get all downloaded Ruqiyah audio IDs
  Future<List<int>> getDownloadedRuqiyahAudios() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final downloadedAudios = <int>[];

    for (final key in keys) {
      if (key.startsWith('ruqiyah_') && key.endsWith('_downloaded')) {
        final isDownloaded = prefs.getBool(key) ?? false;
        if (isDownloaded) {
          final audioId = int.tryParse(
            key.replaceAll('ruqiyah_', '').replaceAll('_downloaded', ''),
          );
          if (audioId != null) {
            downloadedAudios.add(audioId);
          }
        }
      }
    }

    return downloadedAudios;
  }

  // Get total storage used by Ruqiyah audios
  Future<double> getTotalStorageUsed() async {
    try {
      final dir = await _getRuqiyahDirectory();
      if (!await dir.exists()) return 0.0;

      int totalSize = 0;
      await for (final entity in dir.list(recursive: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize / (1024 * 1024); // Convert to MB
    } catch (e) {
      debugPrint('Error calculating storage: $e');
      return 0.0;
    }
  }

  // Delete all downloaded Ruqiyah audios
  Future<void> deleteAllRuqiyahAudios() async {
    try {
      final dir = await _getRuqiyahDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      final keys =
          prefs.getKeys().where((key) => key.startsWith('ruqiyah_')).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }

      debugPrint('Deleted all Ruqiyah audios');
    } catch (e) {
      debugPrint('Error deleting all Ruqiyah audios: $e');
    }
  }

  // Get replay count for an audio (persisted)
  Future<int> getReplayCount(int audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('ruqiyah_${audioId}_replay_count') ?? 1;
    } catch (e) {
      return 1;
    }
  }

  // Set replay count for an audio (persisted)
  Future<void> setReplayCount(int audioId, int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ruqiyah_${audioId}_replay_count', count);
    } catch (e) {
      debugPrint('Error setting replay count: $e');
    }
  }
}
