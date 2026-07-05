import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/quran_editions.dart';
import '../controllers/auth_controller.dart';
import '../services/ad_service.dart';
import '../services/local_manager.dart';
import '../services/surah_storage_service.dart';
import '../views/constants/appcolors.dart';
import '../services/permission_coordinator.dart';

class SurahDetailController extends GetxController with WidgetsBindingObserver {
  final RxMap<String, dynamic> surahData = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> verses = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final int surahNumber;
  final RxBool isAudioLoading = false.obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxInt currentlyPlayingIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isMuted = false.obs;
  final RxInt audioLoadingIndex = (-1).obs;
  final scrollController = ScrollController();
  final RxString loadingStep = 'Initializing...'.obs;
  final ItemScrollController itemScrollController = ItemScrollController();

  final storageService = SurahStorageService();
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isOfflineMode = false.obs;

  final RxString selectedEdition = QuranEditions.defaultEdition.obs;
  final RxBool isTranslationVisible = true.obs;
  final RxBool translationAdUnlocked = false.obs;

  static const String _translationAdUnlockKey =
      'quran_translation_ad_unlock_expiry';

  bool get isPremium => Get.find<AuthController>().isPremium;

  /// Returns true if the user can load translations.
  /// Requires premium subscription or a valid 24-hour ad unlock.
  bool get shouldLoadTranslation => isPremium || translationAdUnlocked.value;

  void scrollToVerse(int index) {
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void toggleMute() async {
    isMuted.toggle();
    if (isMuted.value) {
      await audioPlayer.setVolume(0.0);
    } else {
      await audioPlayer.setVolume(1.0);
    }
  }

  StreamSubscription<void>? _onCompleteSubscription;

  SurahDetailController(this.surahNumber);

  final RxString currentTime = ''.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  Timer? _timeTimer;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    super.onInit();

    _checkOngoingDownload();

    _initTranslationEdition();
    _startTimeUpdater();
    _getLocationStream();
    _onCompleteSubscription = audioPlayer.onPlayerComplete.listen(
      (event) {
        _handleAutoNext();
      },
      onError: (e) {
        debugPrint('AudioPlayer error: $e');
        isPlaying.value = false;
        isAudioLoading.value = false;
      },
    );
  }

  Future<void> _initTranslationEdition() async {
    // Check unlock status first so shouldLoadTranslation is accurate before fetching.
    await _checkTranslationAdUnlock();
    final saved = await LocaleManager.loadTranslationEdition();
    selectedEdition.value = saved;
    fetchSurahData();
  }

  void _checkOngoingDownload() {
    if (storageService.isDownloadInProgress(surahNumber)) {
      isDownloading.value = true;

      final progressObservable =
          storageService.getDownloadProgress(surahNumber);
      if (progressObservable != null) {
        ever(progressObservable, (progress) {
          downloadProgress.value = progress;

          if (progress >= 1.0) {
            isDownloading.value = false;
            downloadProgress.value = 0.0;
            fetchSurahData();
          }
        });

        downloadProgress.value = progressObservable.value;
      }
    }
  }

  Future<void> _checkTranslationAdUnlock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiry = prefs.getInt(_translationAdUnlockKey) ?? 0;
      translationAdUnlocked.value =
          expiry > DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      translationAdUnlocked.value = false;
    }
  }

  Future<void> _saveTranslationAdUnlock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiry =
          DateTime.now().millisecondsSinceEpoch + (24 * 60 * 60 * 1000);
      await prefs.setInt(_translationAdUnlockKey, expiry);
      translationAdUnlocked.value = true;
    } catch (e) {
      debugPrint('SurahDetailController._saveTranslationAdUnlock error: $e');
    }
  }

  Future<void> watchAdForTranslationUnlock() async {
    await AdService.instance.showRewardedAdIfReady(
      onRewarded: () async {
        await _saveTranslationAdUnlock();
        await fetchSurahData();
      },
    );
  }

  Future<void> fetchSurahData() async {
    try {
      isLoading.value = true;

      final isDownloaded = await storageService.isSurahDownloaded(surahNumber);

      if (isDownloaded) {
        loadingStep.value = "Loading from offline storage...";
        final cachedData = await storageService.getDownloadedSurah(surahNumber);

        if (cachedData != null) {
          surahData.value = cachedData['surahData'];
          final cachedVerses =
              List<Map<String, dynamic>>.from(cachedData['verses']);
          isOfflineMode.value = true;

          if (shouldLoadTranslation) {
            loadingStep.value = "Loading translation...";
            try {
              final dioClient = dio.Dio();
              final transUrl =
                  '${QuranEditions.baseUrl}/v1/surah/$surahNumber/${selectedEdition.value}';
              final transResponse = await dioClient.get(transUrl);
              if (transResponse.statusCode == 200) {
                final transAyahs =
                    transResponse.data['data']?['ayahs'] as List?;
                verses.value = List.generate(cachedVerses.length, (i) {
                  final v = Map<String, dynamic>.from(cachedVerses[i]);
                  v['translation'] =
                      (transAyahs != null && i < transAyahs.length)
                          ? (transAyahs[i]['text'] ?? '')
                          : '';
                  return v;
                });
              } else {
                verses.value = cachedVerses;
              }
            } catch (_) {
              verses.value = cachedVerses;
            }
          } else {
            verses.value = cachedVerses;
          }

          loadingStep.value = "Surah loaded from offline storage";
          error.value = '';
          return;
        } else {
          // Data is marked as downloaded but couldn't be loaded
          // This indicates corruption - the isSurahDownloaded check should have cleaned it up
          // But if we reach here, force a re-download by setting isOfflineMode to false
          debugPrint(
              'Warning: Surah $surahNumber marked as downloaded but data is null');
          isOfflineMode.value = false;
        }
      }

      // Fetch from API if not downloaded
      isOfflineMode.value = false;
      loadingStep.value = "Fetching Surah data...";

      final dioClient = dio.Dio();
      final base = QuranEditions.baseUrl;
      final arabicUrl = '$base/v1/surah/$surahNumber/quran-uthmani';
      final audioApiUrl =
          '$base/v1/surah/$surahNumber/${QuranEditions.audioEdition}';

      final futures = <Future<dio.Response>>[
        dioClient.get(arabicUrl),
        dioClient.get(audioApiUrl),
        if (shouldLoadTranslation)
          dioClient.get('$base/v1/surah/$surahNumber/${selectedEdition.value}'),
      ];
      final results = await Future.wait(futures);

      final arabicResponse = results[0];
      final audioResponse = results[1];

      if (arabicResponse.statusCode != 200) {
        Get.snackbar(
          "Error",
          'Failed to load Arabic text',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.bgColorThemed(Get.context!),
          colorText: AppColors.blackTextThemed(Get.context!),
          duration: const Duration(seconds: 3),
        );
        throw Exception('Failed to load Arabic text.');
      }
      if (audioResponse.statusCode != 200) {
        Get.snackbar(
          "Error",
          'Failed to load Audio',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.bgColorThemed(Get.context!),
          colorText: AppColors.blackTextThemed(Get.context!),
          duration: const Duration(seconds: 3),
        );
        throw Exception('Failed to load Audio.');
      }

      final arabicData = arabicResponse.data['data'];
      final audioData = audioResponse.data['data'];

      List? transAyahs;
      if (shouldLoadTranslation &&
          results.length > 2 &&
          results[2].statusCode == 200) {
        transAyahs = results[2].data['data']?['ayahs'] as List?;
      }

      loadingStep.value = "Preparing Surah info...";
      surahData.value = {
        'number': arabicData['number'],
        'name': arabicData['englishName'],
        'nameArabic': arabicData['name']
            .toString()
            .replaceAll(
                RegExp(
                    r'س[\u064B-\u0652]*و[\u064B-\u0652]*ر[\u064B-\u0652]*ة[\u064B-\u0652]*\s*'),
                '')
            .trim(),
        'revelationType': arabicData['revelationType'],
        'numberOfAyahs': arabicData['numberOfAyahs'],
      };

      loadingStep.value = "Merging verses...";
      final arabicAyahs = arabicData['ayahs'] as List;
      final audioAyahs = audioData['ayahs'] as List;

      verses.value = List.generate(arabicAyahs.length, (i) {
        return {
          'number': arabicAyahs[i]['numberInSurah'],
          'text': arabicAyahs[i]['text'],
          'audio': audioAyahs[i]['audio'],
          'translation': (transAyahs != null && i < transAyahs.length)
              ? (transAyahs[i]['text'] ?? '')
              : '',
        };
      });
      loadingStep.value = "Surah loaded successfully";
      error.value = '';
    } on SocketException {
      Get.snackbar(
        "No Internet Connection",
        "Please check your internet connection and try again",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      error.value = 'No internet connection. Please check your network.';
    } on dio.DioException catch (e) {
      if (e.type == dio.DioExceptionType.connectionError) {
        Get.snackbar(
          "No Internet Connection",
          "Please check your internet connection and try again",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.bgColorThemed(Get.context!),
          colorText: AppColors.blackTextThemed(Get.context!),
          duration: const Duration(seconds: 3),
        );
        error.value = 'No internet connection. Please check your network.';
      } else {
        Get.snackbar(
          "Error",
          "Failed to load Surah data. Please try again later.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.bgColorThemed(Get.context!),
          colorText: AppColors.blackTextThemed(Get.context!),
          duration: const Duration(seconds: 3),
        );
        error.value = 'Error fetching Surah data: $e';
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load Surah data. Please try again later.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      error.value = 'Error fetching Surah data: $e';
      debugPrint('Error fetching Surah data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void retry() {
    error.value = '';
    fetchSurahData();
  }

  Future<void> changeEdition(String edition) async {
    if (!shouldLoadTranslation) {
      Get.snackbar(
        'Translation Locked',
        'Watch an ad to unlock all translations for 24h, or subscribe to Premium.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    selectedEdition.value = edition;
    await LocaleManager.saveTranslationEdition(edition);
    if (isOfflineMode.value) {
      Get.snackbar(
        "Translation Changed",
        "Re-download to update offline copy.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      return;
    }
    await fetchSurahData();
  }

  Future<void> playVerseAt(int index) async {
    if (index < 0 || index >= verses.length) return;

    try {
      isAudioLoading.value = true;
      audioLoadingIndex.value = index;

      final audioPath = verses[index]['audio'];

      // Guard: skip if audio path is null or empty
      if (audioPath == null || (audioPath as String).trim().isEmpty) {
        debugPrint('playVerseAt: audio path is null/empty for verse $index');
        isPlaying.value = false;
        return;
      }

      await audioPlayer.stop();

      if (audioPath.startsWith('http')) {
        await audioPlayer.setSourceUrl(audioPath);
      } else {
        final file = File(audioPath);
        if (!await file.exists()) {
          debugPrint('playVerseAt: local file missing at $audioPath');

          Get.snackbar(
            'Offline File Missing',
            'Could not find the local audio file. Please re-download the surah.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          isPlaying.value = false;
          return;
        }
        await audioPlayer.setSourceDeviceFile(audioPath);
      }

      await audioPlayer.resume();

      currentlyPlayingIndex.value = index;
      isPlaying.value = true;
      scrollToVerse(index);
    } catch (e) {
      debugPrint('playVerseAt error at verse $index: $e');
      isPlaying.value = false;
      Get.snackbar(
        'Playback Error',
        'Could not play this verse. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isAudioLoading.value = false;
      audioLoadingIndex.value = -1;
    }
  }

  void _handleAutoNext() {
    final nextIndex = currentlyPlayingIndex.value + 1;

    if (nextIndex < verses.length) {
      playVerseAt(nextIndex);
    } else {
      isPlaying.value = false;
      currentlyPlayingIndex.value = -1;
      audioPlayer.stop();
    }
  }

  Future<void> togglePlayPause(int index) async {
    if (currentlyPlayingIndex.value == index && isPlaying.value) {
      await audioPlayer.pause();
      isPlaying.value = false;
    } else {
      await playVerseAt(index);
    }
  }

  Future<void> toggleTopPlayPause() async {
    if (isPlaying.value) {
      await audioPlayer.pause();
      isPlaying.value = false;
    } else {
      if (currentlyPlayingIndex.value == -1 && verses.isNotEmpty) {
        await playVerseAt(0);
      } else {
        await audioPlayer.resume();
        isPlaying.value = true;
      }
    }
  }

  void playNextVerse() {
    final nextIndex = currentlyPlayingIndex.value + 1;
    if (nextIndex < verses.length) {
      playVerseAt(nextIndex);
    }
  }

  void playPreviousVerse() {
    final prevIndex = currentlyPlayingIndex.value - 1;
    if (prevIndex >= 0) {
      playVerseAt(prevIndex);
    }
  }

  void stopAudio() async {
    await audioPlayer.stop();
    isPlaying.value = false;
  }

  Future<void> downloadSurah() async {
    try {
      final isDownloaded = await storageService.isSurahDownloaded(surahNumber);
      if (isDownloaded) {
        Get.snackbar(
          "Already Downloaded",
          "This surah is already available offline",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.bgColorThemed(Get.context!),
          colorText: AppColors.blackTextThemed(Get.context!),
          duration: const Duration(seconds: 2),
        );
        return;
      }

      isDownloading.value = true;
      downloadProgress.value = 0.0;

      await storageService.downloadSurah(
        surahNumber: surahNumber,
        surahData: Map<String, dynamic>.from(surahData),
        verses: verses.map((v) => Map<String, dynamic>.from(v)).toList(),
        onProgress: (progress) {
          downloadProgress.value = progress;
        },
      );

      Get.snackbar(
        "Download Complete",
        "${surahData['name']} is now available offline",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );

      await fetchSurahData();
    } on SocketException {
      Get.snackbar(
        "No Internet Connection",
        "Download failed. Please check your internet connection.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        "Download Failed",
        "Failed to download surah. Please try again later.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  Future<void> deleteSurah() async {
    try {
      await storageService.deleteSurah(surahNumber);
      Get.snackbar(
        "Deleted",
        "${surahData['name']} removed from offline storage",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 2),
      );

      await fetchSurahData();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete surah: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeTimer?.cancel();
    _positionSubscription?.cancel();
    _onCompleteSubscription?.cancel();
    stopAudio();
    audioPlayer.dispose();
    if (surahData.isNotEmpty) {
      LocaleManager.saveLastReadSurah(
        surahNumber: surahNumber,
        surahName: surahData['name'] ?? '',
        verseIndex:
            currentlyPlayingIndex.value < 0 ? 0 : currentlyPlayingIndex.value,
      );
    }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Engine is detaching — stop immediately so audioplayers releases its
      // platform channel before the engine is torn down.
      stopAudio();
    }
  }

  void _startTimeUpdater() {
    currentTime.value =
        DateFormat('hh:mm:ss a', 'en_US').format(DateTime.now());
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value =
          DateFormat('hh:mm:ss a', 'en_US').format(DateTime.now());
    });
  }

  void _getLocationStream() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await PermissionCoordinator()
            .run(() => Geolocator.requestPermission());
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        (Position position) {
          latitude.value = position.latitude;
          longitude.value = position.longitude;
        },
        onError: (e) =>
            debugPrint('Location stream error (e.g. GPS disabled): $e'),
      );
    } catch (e) {
      debugPrint('Location stream error (e.g. GPS disabled): $e');
    }
  }
}
