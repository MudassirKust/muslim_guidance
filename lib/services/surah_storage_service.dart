import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurahStorageService {
  static final SurahStorageService _instance = SurahStorageService._internal();
  factory SurahStorageService() => _instance;
  SurahStorageService._internal();

  final Dio _dio = Dio();

  // Track ongoing downloads: Map<surahNumber, progressObservable>
  final Map<int, RxDouble> _ongoingDownloads = {};

  // Check if a download is in progress for a specific surah
  bool isDownloadInProgress(int surahNumber) {
    return _ongoingDownloads.containsKey(surahNumber);
  }

  // Get progress observable for ongoing download
  RxDouble? getDownloadProgress(int surahNumber) {
    return _ongoingDownloads[surahNumber];
  }

  // Get the directory for storing surah data
  Future<Directory> _getSurahDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final surahDir = Directory('${appDir.path}/surahs');
    if (!await surahDir.exists()) {
      await surahDir.create(recursive: true);
    }
    return surahDir;
  }

  // Check if a surah is downloaded AND verify data integrity
  Future<bool> isSurahDownloaded(int surahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMarkedDownloaded =
          prefs.getBool('surah_${surahNumber}_downloaded') ?? false;

      if (!isMarkedDownloaded) return false;

      // Verify the download is actually complete and valid
      final dir = await _getSurahDirectory();
      final surahFile = File('${dir.path}/surah_$surahNumber.json');
      final audioDir = Directory('${dir.path}/surah_${surahNumber}_audio');

      // Check if files exist
      if (!await surahFile.exists() || !await audioDir.exists()) {
        debugPrint(
            'Surah $surahNumber marked as downloaded but files missing. Cleaning up flag.');
        await prefs.remove('surah_${surahNumber}_downloaded');
        return false;
      }

      // Verify JSON file is readable
      try {
        final content = await surahFile.readAsString();
        final data = json.decode(content);
        final verses = data['verses'] as List;

        // Verify all audio files exist
        for (final verse in verses) {
          final audioPath = verse['audio'];
          final audioFile = File(audioPath);
          if (!await audioFile.exists()) {
            debugPrint(
                'Surah $surahNumber audio file missing: $audioPath. Cleaning up.');
            await _cleanupIncompleteDownload(surahNumber);
            return false;
          }

          // Verify file is not corrupted (has reasonable size)
          final fileSize = await audioFile.length();
          if (fileSize < 1024) {
            debugPrint(
                'Surah $surahNumber has corrupted audio file: $audioPath (size: $fileSize). Cleaning up.');
            await _cleanupIncompleteDownload(surahNumber);
            return false;
          }
        }

        return true;
      } catch (e) {
        debugPrint('Surah $surahNumber JSON file corrupted: $e. Cleaning up.');
        await _cleanupIncompleteDownload(surahNumber);
        return false;
      }
    } catch (e) {
      debugPrint('Error verifying surah download: $e');
      return false;
    }
  }

  // Clean up incomplete or corrupted downloads
  Future<void> _cleanupIncompleteDownload(int surahNumber) async {
    try {
      final dir = await _getSurahDirectory();
      final surahFile = File('${dir.path}/surah_$surahNumber.json');
      final audioDir = Directory('${dir.path}/surah_${surahNumber}_audio');

      if (await surahFile.exists()) {
        await surahFile.delete();
      }

      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('surah_${surahNumber}_downloaded');

      debugPrint('Cleaned up incomplete download for surah $surahNumber');
    } catch (e) {
      debugPrint('Error cleaning up incomplete download: $e');
    }
  }

  // Get downloaded surah data
  Future<Map<String, dynamic>?> getDownloadedSurah(int surahNumber) async {
    try {
      final isDownloaded = await isSurahDownloaded(surahNumber);
      if (!isDownloaded) return null;

      final dir = await _getSurahDirectory();
      final file = File('${dir.path}/surah_$surahNumber.json');

      if (!await file.exists()) return null;

      final content = await file.readAsString();
      return json.decode(content);
    } catch (e) {
      debugPrint('Error reading downloaded surah: $e');
      return null;
    }
  }

  // Check available storage space
  Future<bool> hasEnoughStorage(double requiredMB) async {
    try {
      // final dir = await _getSurahDirectory();
      // final stat = await dir.stat();
      // Note: This is approximate, actual free space check requires platform-specific code
      // For now, we'll rely on download error handling
      return true;
    } catch (e) {
      return true;
    }
  }

  // Download a complete surah with all audio files
  Future<void> downloadSurah({
    required int surahNumber,
    required Map<String, dynamic> surahData,
    required List<Map<String, dynamic>> verses,
    required Function(double) onProgress,
    CancelToken? cancelToken,
  }) async {
    // Register this download in ongoing downloads map
    final progressObservable = RxDouble(0.0);
    _ongoingDownloads[surahNumber] = progressObservable;

    try {
      final dir = await _getSurahDirectory();
      final audioDir = Directory('${dir.path}/surah_${surahNumber}_audio');

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      // Configure Dio for large file downloads
      _dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(seconds: 30),
      );

      // Download all audio files
      final totalVerses = verses.length;
      final downloadedVerses = <Map<String, dynamic>>[];

      for (int i = 0; i < verses.length; i++) {
        final verse = verses[i];
        final audioUrl = verse['audio'];
        final verseNumber = verse['number'];

        // Download audio file with retry logic
        final audioPath = '${audioDir.path}/verse_$verseNumber.mp3';

        // Check if file already exists and is valid (for resume support)
        final audioFile = File(audioPath);
        if (await audioFile.exists()) {
          // Verify file is valid (not corrupted/empty)
          final fileSize = await audioFile.length();
          if (fileSize > 1024) {
            // File should be at least 1KB
            // Skip already downloaded and valid files
            downloadedVerses.add({
              'number': verse['number'],
              'text': verse['text'],
              'audio': audioPath,
            });
            final progress = (i + 1) / totalVerses;
            onProgress(progress);
            progressObservable.value = progress;
            continue;
          } else {
            // File is too small/corrupted, delete and re-download
            debugPrint(
                'Deleting corrupted/incomplete file: $audioPath (size: $fileSize bytes)');
            await audioFile.delete();
          }
        }

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
                  // Calculate overall progress
                  final verseProgress = (received / total) * (1 / totalVerses);
                  final totalProgress = (i / totalVerses) + verseProgress;
                  onProgress(totalProgress);
                  // Update the observable for other screens
                  progressObservable.value = totalProgress;
                }
              },
            );
            downloaded = true;
          } catch (e) {
            retries--;
            if (retries == 0) rethrow;
            await Future.delayed(Duration(seconds: 2));
          }
        }

        // Store verse with local audio path
        downloadedVerses.add({
          'number': verse['number'],
          'text': verse['text'],
          'audio': audioPath, // Local path instead of URL
        });
      }

      // Save surah metadata and verses to JSON file
      final surahFile = File('${dir.path}/surah_$surahNumber.json');
      final surahJson = {
        'surahData': surahData,
        'verses': downloadedVerses,
        'downloadedAt': DateTime.now().toIso8601String(),
      };
      await surahFile.writeAsString(json.encode(surahJson));

      // Verify the JSON file is readable before marking as downloaded
      try {
        final verifyContent = await surahFile.readAsString();
        final verifyData = json.decode(verifyContent);

        // Verify we have all expected data
        if (verifyData['verses'] == null ||
            (verifyData['verses'] as List).length != downloadedVerses.length) {
          throw Exception('JSON verification failed: verse count mismatch');
        }

        // Verify all audio files exist and have valid size
        for (final verse in downloadedVerses) {
          final audioFile = File(verse['audio']);
          if (!await audioFile.exists()) {
            throw Exception(
                'Audio file missing after download: ${verse['audio']}');
          }
          final fileSize = await audioFile.length();
          if (fileSize < 1024) {
            throw Exception(
                'Audio file too small (corrupted): ${verse['audio']}');
          }
        }

        debugPrint('Download verification passed for surah $surahNumber');
      } catch (e) {
        debugPrint('Download verification failed: $e');
        // Clean up and rethrow
        await _cleanupIncompleteDownload(surahNumber);
        throw Exception('Download verification failed: $e');
      }

      // Mark as downloaded only after verification passes
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('surah_${surahNumber}_downloaded', true);

      onProgress(1.0); // Complete
      progressObservable.value = 1.0;
    } catch (e) {
      debugPrint('Error downloading surah: $e');
      // Don't delete on error - allows resume
      rethrow;
    } finally {
      // Unregister from ongoing downloads
      _ongoingDownloads.remove(surahNumber);
    }
  }

  // Delete a downloaded surah
  Future<void> deleteSurah(int surahNumber) async {
    try {
      final dir = await _getSurahDirectory();
      final surahFile = File('${dir.path}/surah_$surahNumber.json');
      final audioDir = Directory('${dir.path}/surah_${surahNumber}_audio');

      if (await surahFile.exists()) {
        await surahFile.delete();
      }

      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('surah_${surahNumber}_downloaded');
    } catch (e) {
      debugPrint('Error deleting surah: $e');
    }
  }

  // Get all downloaded surah numbers
  Future<List<int>> getDownloadedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final downloadedSurahs = <int>[];

    for (final key in keys) {
      if (key.startsWith('surah_') && key.endsWith('_downloaded')) {
        final isDownloaded = prefs.getBool(key) ?? false;
        if (isDownloaded) {
          final surahNumber = int.tryParse(
            key.replaceAll('surah_', '').replaceAll('_downloaded', ''),
          );
          if (surahNumber != null) {
            downloadedSurahs.add(surahNumber);
          }
        }
      }
    }

    return downloadedSurahs;
  }

  // Get download size estimate (in MB)
  Future<double> getEstimatedSize(List<Map<String, dynamic>> verses) async {
    // Average MP3 size per verse is approximately 50KB
    const averageSizePerVerse = 50 * 1024; // in bytes
    final totalSize = verses.length * averageSizePerVerse;
    return totalSize / (1024 * 1024); // Convert to MB
  }

  // Get total storage used by downloaded surahs
  Future<double> getTotalStorageUsed() async {
    try {
      final dir = await _getSurahDirectory();
      if (!await dir.exists()) return 0.0;

      int totalSize = 0;
      await for (final entity in dir.list(recursive: true)) {
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

  // Save surah list to local storage
  Future<void> saveSurahList(List<Map<String, dynamic>> surahs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surahListJson = json.encode(surahs);
      await prefs.setString('surah_list', surahListJson);
      await prefs.setString(
          'surah_list_timestamp', DateTime.now().toIso8601String());
      debugPrint('Surah list saved to local storage');
    } catch (e) {
      debugPrint('Error saving surah list: $e');
    }
  }

  // Load surah list from local storage
  Future<List<Map<String, dynamic>>?> loadSurahList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surahListJson = prefs.getString('surah_list');

      if (surahListJson == null) return null;

      final List<dynamic> decoded = json.decode(surahListJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      debugPrint('Error loading surah list: $e');
      return null;
    }
  }

  // Check if surah list exists in local storage
  Future<bool> hasSurahList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('surah_list');
    } catch (e) {
      return false;
    }
  }
}
