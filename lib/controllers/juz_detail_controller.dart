import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/quran_editions.dart';
import '../controllers/auth_controller.dart';
import '../models/juz_model.dart';
import '../services/ad_service.dart';
import '../services/local_manager.dart';
import '../views/constants/appcolors.dart';

class JuzDetailController extends GetxController with WidgetsBindingObserver {
  final int juzNumber;

  JuzDetailController(this.juzNumber);

  late ParahInfo parahInfo;

  final RxList<JuzVerse> verses = <JuzVerse>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxString loadingStep = 'Initializing...'.obs;

  final AudioPlayer audioPlayer = AudioPlayer();
  final RxInt currentlyPlayingIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isMuted = false.obs;
  final RxBool isAudioLoading = false.obs;
  final RxInt audioLoadingIndex = (-1).obs;

  final ItemScrollController itemScrollController = ItemScrollController();

  final RxString selectedEdition = QuranEditions.defaultEdition.obs;
  final RxBool isTranslationVisible = true.obs;
  final RxBool translationAdUnlocked = false.obs;

  static const String _translationAdUnlockKey =
      'quran_translation_ad_unlock_expiry';

  bool get isPremium => Get.find<AuthController>().isPremium;
  bool get shouldLoadTranslation => isPremium || translationAdUnlocked.value;

  StreamSubscription<void>? _onCompleteSubscription;

  // Items are either SurahSeparatorMarker or MapEntry<int, JuzVerse>
  // where the key is the verse index in [verses]. This avoids O(n) indexOf
  // lookups in the list builder.
  List<dynamic> get listItems {
    final items = <dynamic>[];
    int? lastSurah;
    int verseIdx = 0;
    for (final verse in verses) {
      if (verse.surahNumber != lastSurah) {
        items.add(SurahSeparatorMarker(
          surahNumber: verse.surahNumber,
          englishName: verse.surahEnglishName,
          arabicName: verse.surahArabicName,
        ));
        lastSurah = verse.surahNumber;
      }
      items.add(MapEntry<int, JuzVerse>(verseIdx, verse));
      verseIdx++;
    }
    return items;
  }

  int listIndexForVerseIndex(int verseIndex) {
    final items = listItems;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is MapEntry<int, JuzVerse> && item.key == verseIndex) return i;
    }
    return verseIndex;
  }

  void scrollToVerse(int verseIndex) {
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: listIndexForVerseIndex(verseIndex),
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

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    super.onInit();
    parahInfo = ParahInfo.all[juzNumber - 1];
    _initTranslationEdition();
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
    await _checkTranslationAdUnlock();
    final saved = await LocaleManager.loadTranslationEdition();
    selectedEdition.value = saved;
    fetchJuzData();
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
      debugPrint('JuzDetailController._saveTranslationAdUnlock error: $e');
    }
  }

  Future<void> watchAdForTranslationUnlock() async {
    await AdService.instance.showRewardedAdIfReady(
      onRewarded: () async {
        await _saveTranslationAdUnlock();
        await fetchJuzData();
      },
    );
  }

  Future<void> fetchJuzData() async {
    try {
      isLoading.value = true;
      loadingStep.value = 'Fetching Parah data...';

      final dioClient = dio.Dio();
      final base = QuranEditions.baseUrl;
      final arabicUrl = '$base/v1/juz/$juzNumber/quran-uthmani';
      final audioApiUrl =
          '$base/v1/juz/$juzNumber/${QuranEditions.audioEdition}';

      final futures = <Future<dio.Response>>[
        dioClient.get(arabicUrl),
        dioClient.get(audioApiUrl),
        if (shouldLoadTranslation)
          dioClient.get('$base/v1/juz/$juzNumber/${selectedEdition.value}'),
      ];
      final results = await Future.wait(futures);

      final arabicResponse = results[0];
      final audioResponse = results[1];

      if (arabicResponse.statusCode != 200) {
        throw Exception('Failed to load Arabic text.');
      }
      if (audioResponse.statusCode != 200) {
        throw Exception('Failed to load audio.');
      }

      final arabicAyahs = arabicResponse.data['data']['ayahs'] as List;
      final audioAyahs = audioResponse.data['data']['ayahs'] as List;

      List? transAyahs;
      if (shouldLoadTranslation &&
          results.length > 2 &&
          results[2].statusCode == 200) {
        transAyahs = results[2].data['data']?['ayahs'] as List?;
      }

      loadingStep.value = 'Merging verses...';
      verses.value = List.generate(arabicAyahs.length, (i) {
        final arabic = arabicAyahs[i];
        final surah = arabic['surah'] as Map<String, dynamic>;
        return JuzVerse(
          globalNumber: arabic['number'] as int,
          numberInSurah: arabic['numberInSurah'] as int,
          surahNumber: surah['number'] as int,
          text: arabic['text'] as String? ?? '',
          audio: audioAyahs[i]['audio'] as String? ?? '',
          translation: (transAyahs != null && i < transAyahs.length)
              ? (transAyahs[i]['text'] as String? ?? '')
              : '',
          surahArabicName: surah['name'] as String? ?? '',
          surahEnglishName: surah['englishName'] as String? ?? '',
        );
      });

      loadingStep.value = 'Parah loaded successfully';
      error.value = '';
    } on SocketException {
      Get.snackbar(
        'No Internet Connection',
        'Please check your internet connection and try again',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      error.value = 'No internet connection. Please check your network.';
    } on dio.DioException catch (e) {
      if (e.type == dio.DioExceptionType.connectionError) {
        Get.snackbar(
          'No Internet Connection',
          'Please check your internet connection and try again',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.bgColorThemed(Get.context!),
          colorText: AppColors.blackTextThemed(Get.context!),
          duration: const Duration(seconds: 3),
        );
        error.value = 'No internet connection. Please check your network.';
      } else {
        Get.snackbar(
          'Error',
          'Failed to load Parah data. Please try again later.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.bgColorThemed(Get.context!),
          colorText: AppColors.blackTextThemed(Get.context!),
          duration: const Duration(seconds: 3),
        );
        error.value = 'Error fetching Parah data: $e';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load Parah data. Please try again later.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      error.value = 'Error fetching Parah data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void retry() {
    error.value = '';
    fetchJuzData();
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
    await fetchJuzData();
  }

  Future<void> playVerseAt(int index) async {
    if (index < 0 || index >= verses.length) return;

    try {
      isAudioLoading.value = true;
      audioLoadingIndex.value = index;

      final audioPath = verses[index].audio;

      if (audioPath.trim().isEmpty) {
        debugPrint('playVerseAt: audio path is empty for verse $index');
        isPlaying.value = false;
        return;
      }

      await audioPlayer.stop();

      if (audioPath.startsWith('http')) {
        await audioPlayer.setSourceUrl(audioPath);
      } else {
        final file = File(audioPath);
        if (!await file.exists()) {
          Get.snackbar(
            'Offline File Missing',
            'Could not find the local audio file.',
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

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _onCompleteSubscription?.cancel();
    stopAudio();
    audioPlayer.dispose();
    LocaleManager.saveLastReadParah(
      juzNumber: juzNumber,
      commonName: parahInfo.commonName,
      verseIndex:
          currentlyPlayingIndex.value < 0 ? 0 : currentlyPlayingIndex.value,
    );
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      stopAudio();
    }
  }
}
