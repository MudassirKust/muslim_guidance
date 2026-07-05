import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/ruqiyah_model.dart';
import '../services/ruqiyah_storage_service.dart';

class RuqiyahController extends GetxController with WidgetsBindingObserver {
  // Audio data
  final RxList<RuqiyahAudio> audios = <RuqiyahAudio>[].obs;
  final RxBool isLoading = true.obs;

  // Playback state
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxInt currentlyPlayingIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isAudioLoading = false.obs;
  final RxInt audioLoadingIndex = (-1).obs;
  final RxDouble currentProgress = 0.0.obs;
  final RxString currentDuration = '0:00'.obs;
  final RxString totalDuration = '0:00'.obs;
  final RxBool isMuted = false.obs;

  // Track audio duration (from stream)
  Duration? _audioDuration;

  // Play All mode
  final RxBool isPlayAllMode = false.obs;
  final RxInt currentPlayAllIndex = (-1).obs;
  final RxInt currentReplayIteration = 0.obs;

  // Download state (per audio ID)
  final RxMap<int, bool> downloadStatus = <int, bool>{}.obs;
  final RxMap<int, double> downloadProgress = <int, double>{}.obs;
  final RxMap<int, bool> isDownloading = <int, bool>{}.obs;

  // Replay counts (per audio ID)
  final RxMap<int, int> replayCounts = <int, int>{}.obs;

  // Storage service
  final storageService = RuqiyahStorageService();

  // Stream subscriptions
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  // Constants
  static const int minReplayCount = 1;
  static const int maxReplayCount = 10;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    _loadRuqiyahData();

    _playerStateSubscription = audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleAudioCompletion();
      }
      isPlaying.value = state.playing;
    });

    _durationSubscription = audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _audioDuration = duration;
        totalDuration.value = _formatDuration(duration);
      }
    });

    _positionSubscription = audioPlayer.positionStream.listen((position) {
      currentDuration.value = _formatDuration(position);

      // Update progress (0.0 to 1.0)
      if (_audioDuration != null) {
        final total = _audioDuration!.inMilliseconds;
        if (total > 0) {
          currentProgress.value = position.inMilliseconds / total;
        }
      }
    });
  }

  @override
  void onClose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop audio when the engine is about to detach so the background service
    // releases its engine reference before FlutterActivityAndFragmentDelegate
    // calls detachFromFlutterEngine — prevents AssertionError in production.
    if (state == AppLifecycleState.detached) {
      audioPlayer.stop();
    }
    // Background playback (paused/inactive states) is intentionally allowed via
    // JustAudioBackground so audio continues when the screen locks.
  }

  // Load the 6 Ruqiyah audio items
  Future<void> _loadRuqiyahData() async {
    try {
      isLoading.value = true;

      // Initialize the 6 Ruqiyah audios
      audios.value = [
        RuqiyahAudio(
          id: 1,
          titleArabic: 'السحر',
          titleEnglish: 'Magic',
          descriptionKey: 'ruqiyah_magic_desc',
          audioUrl:
              'https://firebasestorage.googleapis.com/v0/b/muslimguidance-b8fe9.firebasestorage.app/o/Magic_cure.m4a?alt=media&token=36cca765-8d25-4e31-9224-336c1de04e5e',
          replayCount: 1,
        ),
        RuqiyahAudio(
          id: 2,
          titleArabic: 'العين',
          titleEnglish: 'Evil Eye',
          descriptionKey: 'ruqiyah_evil_eye_desc',
          audioUrl:
              'https://firebasestorage.googleapis.com/v0/b/muslimguidance-b8fe9.firebasestorage.app/o/Evileyecure.m4a?alt=media&token=29a204b4-dde1-4ae0-8445-fef1a7308a1f',
          replayCount: 1,
        ),
        RuqiyahAudio(
          id: 3,
          titleArabic: 'المس',
          titleEnglish: 'Possession',
          descriptionKey: 'ruqiyah_possession_desc',
          audioUrl:
              'https://firebasestorage.googleapis.com/v0/b/muslimguidance-b8fe9.firebasestorage.app/o/evil%20spirit_Jin%20cure.m4a?alt=media&token=c7b7f855-0cbe-4b5e-981d-a9b04c859ed9',
          replayCount: 1,
        ),
        RuqiyahAudio(
          id: 4,
          titleArabic: 'الحسد',
          titleEnglish: 'Jealousy',
          descriptionKey: 'ruqiyah_jealousy_desc',
          audioUrl:
              'https://firebasestorage.googleapis.com/v0/b/muslimguidance-b8fe9.firebasestorage.app/o/Jealousyhasad.mp3?alt=media&token=e1b382ba-96be-49e5-bbee-cf57a494cb3c',
          replayCount: 1,
        ),
        RuqiyahAudio(
          id: 5,
          titleArabic: 'سحر المحبة',
          titleEnglish: 'Love Magic',
          descriptionKey: 'ruqiyah_love_magic_desc',
          audioUrl:
              'https://firebasestorage.googleapis.com/v0/b/muslimguidance-b8fe9.firebasestorage.app/o/Love%20magic%20cure.m4a?alt=media&token=dc823f66-0e58-4fd1-8b8c-a5290e0b1f74',
          replayCount: 1,
        ),
        RuqiyahAudio(
          id: 6,
          titleArabic: 'الأمراض النفسية والجسدية',
          titleEnglish: 'Overall Healing',
          descriptionKey: 'ruqiyah_overall_healing_desc',
          audioUrl:
              'https://firebasestorage.googleapis.com/v0/b/muslimguidance-b8fe9.firebasestorage.app/o/dua%20supplication%20physical%20emotional%20spiritual%20ailments.mp3?alt=media&token=99bec801-700d-4e44-a597-d0107f911d40',
          replayCount: 1,
        ),
      ];

      // Load download status and replay counts for each audio
      for (final audio in audios) {
        await _checkAudioStatus(audio.id);
      }

      isLoading.value = false;
    } catch (e) {
      debugPrint('Error loading Ruqiyah data: $e');
      isLoading.value = false;
    }
  }

  Future<void> _checkAudioStatus(int audioId) async {
    final isDownloaded = await storageService.isRuqiyahDownloaded(audioId);
    downloadStatus[audioId] = isDownloaded;

    final replayCount = await storageService.getReplayCount(audioId);
    replayCounts[audioId] = replayCount;

    final index = audios.indexWhere((a) => a.id == audioId);
    if (index != -1) {
      audios[index].replayCount = replayCount;
    }

    if (storageService.isDownloadInProgress(audioId)) {
      isDownloading[audioId] = true;
      final progressObservable = storageService.getDownloadProgress(audioId);
      if (progressObservable != null) {
        ever(progressObservable, (progress) {
          downloadProgress[audioId] = progress;
          if (progress >= 1.0) {
            isDownloading[audioId] = false;
            downloadStatus[audioId] = true;
          }
        });
      }
    }
  }

  // Play audio at specific index
  Future<void> playAudioAt(int index) async {
    if (index < 0 || index >= audios.length) return;

    try {
      final audio = audios[index];

      // Update UI immediately for instant feedback
      currentlyPlayingIndex.value = index;

      // Stop current playback
      await audioPlayer.stop();

      // Check if audio is downloaded locally
      final localPath = await storageService.getLocalAudioPath(audio.id);

      // Create MediaItem for notification metadata
      final mediaItem = MediaItem(
        id: audio.id.toString(),
        title: audio.titleEnglish,
        artist: 'Ruqiyah',
        album: 'Islamic Healing',
        displayTitle: audio.titleArabic,
        displaySubtitle: audio.titleEnglish,
      );

      // Create AudioSource with proper MediaItem tag
      final audioSource = localPath != null
          ? AudioSource.file(localPath, tag: mediaItem)
          : AudioSource.uri(Uri.parse(audio.audioUrl), tag: mediaItem);

      // Set source with minimal buffering and play immediately
      try {
        await audioPlayer.setAudioSource(
          audioSource,
          initialPosition: Duration.zero,
          preload: false, // Don't preload entire file, start ASAP
        );
        await audioPlayer.play();
      } catch (e) {
        // Ignore expected interruption errors when user changes track rapidly
        if (e.toString().contains('abort') ||
            e.toString().contains('interrupted')) {
          debugPrint('Audio loading interrupted');
          return;
        }
        debugPrint('Error loading audio: $e');
        isPlaying.value = false;
        currentlyPlayingIndex.value = -1;
        Get.snackbar(
          'Playback Error',
          'Failed to load audio. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      isPlaying.value = false;
      currentlyPlayingIndex.value = -1;
      Get.snackbar(
        'Playback Error',
        'Failed to play audio. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> togglePlayPause(int index) async {
    try {
      // If same audio is currently playing, pause it
      if (currentlyPlayingIndex.value == index && isPlaying.value) {
        await audioPlayer.pause();
      }
      // If same audio is paused, resume it
      else if (currentlyPlayingIndex.value == index && !isPlaying.value) {
        await audioPlayer.play();
      }
      // Otherwise, play the new audio
      else {
        // Stop Play All mode if active
        if (isPlayAllMode.value) {
          stopPlayAll();
        }
        await playAudioAt(index);
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  // Start Play All mode
  Future<void> startPlayAll() async {
    if (audios.isEmpty) return;

    isPlayAllMode.value = true;
    currentPlayAllIndex.value = 0;
    currentReplayIteration.value = 0;

    await playAudioAt(0);
  }

  // Stop Play All mode
  Future<void> stopPlayAll() async {
    isPlayAllMode.value = false;
    currentPlayAllIndex.value = -1;
    currentReplayIteration.value = 0;

    await audioPlayer.stop();
    currentlyPlayingIndex.value = -1;
  }

  // Handle audio completion (replay logic for Play All)
  Future<void> _handleAudioCompletion() async {
    if (!isPlayAllMode.value) {
      // Normal playback complete - state will be handled by playerStateStream
      currentlyPlayingIndex.value = -1;
      return;
    }

    // Bounds checking for Play All mode
    if (currentPlayAllIndex.value < 0 ||
        currentPlayAllIndex.value >= audios.length) {
      await stopPlayAll();
      return;
    }

    // Play All mode - handle replay logic
    final currentAudio = audios[currentPlayAllIndex.value];
    final maxReplays = replayCounts[currentAudio.id] ?? 1;

    currentReplayIteration.value++;

    // Check if we need to replay current audio
    if (currentReplayIteration.value < maxReplays) {
      // Replay same audio
      try {
        await audioPlayer.seek(Duration.zero);
        await audioPlayer.play();
      } catch (e) {
        debugPrint('Error replaying audio: $e');
      }
      return;
    }

    // Move to next audio
    currentReplayIteration.value = 0;
    currentPlayAllIndex.value++;

    // Check if playlist finished
    if (currentPlayAllIndex.value >= audios.length) {
      // Playlist complete
      await stopPlayAll();
      Get.snackbar(
        'Play All Complete',
        'All Ruqiyah audios have been played.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Play next audio
    await playAudioAt(currentPlayAllIndex.value);
  }

  // Update replay count for an audio
  Future<void> updateReplayCount(int audioId, int count) async {
    if (count < minReplayCount || count > maxReplayCount) return;

    replayCounts[audioId] = count;
    await storageService.setReplayCount(audioId, count);

    // Update audio object
    final index = audios.indexWhere((a) => a.id == audioId);
    if (index != -1) {
      audios[index] = audios[index].copyWith(replayCount: count);
      audios.refresh();
    }
  }

  // Download audio
  Future<void> downloadAudio(int audioId) async {
    final audio = audios.firstWhereOrNull((a) => a.id == audioId);
    if (audio == null) return;

    // Check if already downloaded
    final isDownloaded = await storageService.isRuqiyahDownloaded(audioId);
    if (isDownloaded) {
      Get.snackbar(
        'Already Downloaded',
        'This audio is already available offline.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isDownloading[audioId] = true;
      downloadProgress[audioId] = 0.0;

      await storageService.downloadRuqiyahAudio(
        audioId: audioId,
        audioUrl: audio.audioUrl,
        onProgress: (progress) {
          downloadProgress[audioId] = progress;
        },
      );

      downloadStatus[audioId] = true;
      isDownloading[audioId] = false;

      Get.snackbar(
        'Download Complete',
        '${audio.titleEnglish} is now available offline.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error downloading audio: $e');
      isDownloading[audioId] = false;
      Get.snackbar(
        'Download Failed',
        'Failed to download ${audio.titleEnglish}. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete downloaded audio
  Future<void> deleteAudio(int audioId) async {
    try {
      await storageService.deleteRuqiyahAudio(audioId);
      downloadStatus[audioId] = false;

      final audio = audios.firstWhereOrNull((a) => a.id == audioId);
      Get.snackbar(
        'Deleted',
        '${audio?.titleEnglish ?? 'Audio'} removed from offline storage.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error deleting audio: $e');
    }
  }

  // Toggle mute
  void toggleMute() async {
    isMuted.toggle();
    if (isMuted.value) {
      await audioPlayer.setVolume(0.0);
    } else {
      await audioPlayer.setVolume(1.0);
    }
  }

  // Play next audio (manual navigation)
  Future<void> playNext() async {
    final nextIndex = currentlyPlayingIndex.value + 1;
    if (nextIndex < audios.length) {
      await playAudioAt(nextIndex);
    }
  }

  // Play previous audio (manual navigation)
  Future<void> playPrevious() async {
    final prevIndex = currentlyPlayingIndex.value - 1;
    if (prevIndex >= 0) {
      await playAudioAt(prevIndex);
    }
  }

  // Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${twoDigits(seconds)}';
  }

  // Get total storage used by Ruqiyah
  Future<String> getTotalStorageUsed() async {
    final storageMB = await storageService.getTotalStorageUsed();
    if (storageMB < 1) {
      return '${(storageMB * 1024).toStringAsFixed(1)} KB';
    }
    return '${storageMB.toStringAsFixed(1)} MB';
  }
}
