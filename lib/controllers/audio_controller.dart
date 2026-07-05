import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:async';
import 'dart:io';

import '../constants/quran_editions.dart';
import '../services/local_manager.dart';
import '../services/surah_storage_service.dart';
import '../views/constants/appcolors.dart';

class AudioController extends GetxController {
  // Constants
  static const String _apiUrl = '${QuranEditions.baseUrl}/v1/surah';
  static const Duration _apiTimeout = Duration(seconds: 10);

  // Observables
  final RxList<Map<String, dynamic>> surahs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxString loadingStep = 'Initializing...'.obs;
  final RxBool isOfflineMode = false.obs;
  final Rx<Map<String, dynamic>?> lastReadSurah =
      Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> lastReadParah =
      Rx<Map<String, dynamic>?>(null);

  // Services
  final storageService = SurahStorageService();

  // State management
  bool _isUpdating = false;

  @override
  void onInit() {
    super.onInit();
    fetchSurahs();
    refreshLastRead();
  }

  Future<void> refreshLastRead() async {
    lastReadSurah.value = await LocaleManager.loadLastReadSurah();
    lastReadParah.value = await LocaleManager.loadLastReadParah();
  }

  Future<void> fetchSurahs() async {
    try {
      isLoading.value = true;

      // First, try to load from local storage
      loadingStep.value = "Loading Surah list...";
      final cachedSurahs = await storageService.loadSurahList();

      if (cachedSurahs != null && cachedSurahs.isNotEmpty) {
        surahs.value = cachedSurahs;
        isOfflineMode.value = true;
        loadingStep.value = "Surah list loaded from offline storage";
        isLoading.value = false;

        // Try to update from API in background (don't block UI)
        _updateSurahsFromApi();
      } else {
        // No cached data, must fetch from API
        await _fetchFromApi();
      }
    } catch (e) {
      debugPrint('Error in fetchSurahs: $e');
      error.value = 'Error loading surahs: $e';
    } finally {
      if (isLoading.value) {
        isLoading.value = false;
      }
    }
  }

  // Extract formatting logic to follow DRY principle
  Map<String, dynamic> _formatSurah(Map<String, dynamic> surah) {
    final englishName = (surah['englishName']?.toString() ?? '')
        .replaceFirst(RegExp(r'^Surah\s*', caseSensitive: false), '')
        .trim();
    final arabicName = (surah['name']?.toString() ?? '')
        .replaceAll(
            RegExp(
                r'س[\u064B-\u0652]*و[\u064B-\u0652]*ر[\u064B-\u0652]*ة[\u064B-\u0652]*\s*'),
            '')
        .trim();

    return {
      'number': surah['number'].toString(),
      'name': englishName,
      'nameUrdu': arabicName,
      'location': (surah['revelationType'] == 'Meccan' ? 'MAKKAH' : 'MADINAH')
          .toString(),
      'verses': '${surah['numberOfAyahs']} VERSES',
    };
  }

  // Extract API call logic
  Future<List<Map<String, dynamic>>> _fetchSurahsFromApi() async {
    final dioClient = dio.Dio(dio.BaseOptions(
      connectTimeout: _apiTimeout,
      receiveTimeout: _apiTimeout,
      followRedirects: true,
      maxRedirects: 5,
    ));

    final response = await dioClient.get(_apiUrl);

    if (response.statusCode != 200) {
      throw Exception('Failed to load surahs: ${response.statusCode}');
    }

    final data = response.data;
    final surahsData = data['data'] as List;

    return surahsData
        .map((surah) => _formatSurah(Map<String, dynamic>.from(surah)))
        .toList();
  }

  Future<void> _fetchFromApi() async {
    try {
      loadingStep.value = "Fetching Surah list from API...";
      final formattedSurahs = await _fetchSurahsFromApi();

      loadingStep.value = "Formatting Surah names...";
      surahs.value = formattedSurahs;
      isOfflineMode.value = false;

      // Save to local storage
      loadingStep.value = "Saving to offline storage...";
      await storageService.saveSurahList(formattedSurahs);
      loadingStep.value = "Surah list loaded successfully";
      error.value = '';
    } on SocketException {
      await _handleNoInternet();
    } on TimeoutException {
      await _handleTimeout();
    } on dio.DioException catch (e) {
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout ||
          e.type == dio.DioExceptionType.sendTimeout) {
        await _handleTimeout();
      } else if (e.type == dio.DioExceptionType.connectionError) {
        await _handleNoInternet();
      } else {
        _showErrorSnackbar(
          "Error",
          "Failed to load Surahs. Please try again later.",
        );
        error.value = 'Error fetching surahs: $e';
      }
    } catch (e) {
      _showErrorSnackbar(
        "Error",
        "Failed to load Surahs. Please try again later.",
      );
      error.value = 'Error fetching surahs: $e';
    }
  }

  Future<void> _handleNoInternet() async {
    final cachedSurahs = await storageService.loadSurahList();
    if (cachedSurahs != null && cachedSurahs.isNotEmpty) {
      surahs.value = cachedSurahs;
      isOfflineMode.value = true;
      loadingStep.value = "Loaded from offline storage (No internet)";
      error.value = '';

      _showErrorSnackbar(
        "Offline Mode",
        "Showing saved Surah list. Connect to internet to update.",
      );
    } else {
      _showErrorSnackbar(
        "No Internet Connection",
        "Please check your internet connection and try again",
      );
      error.value = 'No internet connection. Please check your network.';
    }
  }

  Future<void> _handleTimeout() async {
    final cachedSurahs = await storageService.loadSurahList();
    if (cachedSurahs != null && cachedSurahs.isNotEmpty) {
      surahs.value = cachedSurahs;
      isOfflineMode.value = true;
      error.value = '';
      _showErrorSnackbar(
        "Request Timeout",
        "Using cached data. Connection is slow.",
      );
    } else {
      _showErrorSnackbar(
        "Request Timeout",
        "Connection timeout. Please try again.",
      );
      error.value = 'Request timeout. Please try again.';
    }
  }

  Future<void> _updateSurahsFromApi() async {
    // Prevent multiple simultaneous updates
    if (_isUpdating) return;

    try {
      _isUpdating = true;
      final formattedSurahs = await _fetchSurahsFromApi();

      surahs.value = formattedSurahs;
      isOfflineMode.value = false;

      // Save to local storage
      await storageService.saveSurahList(formattedSurahs);
    } catch (e) {
      // Silently fail - we already have cached data
      debugPrint('Background update failed: $e');
    } finally {
      _isUpdating = false;
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.bgColorThemed(Get.context!),
      colorText: AppColors.blackTextThemed(Get.context!),
      duration: const Duration(seconds: 3),
    );
  }

  void retry() {
    error.value = '';
    loadingStep.value = 'Retrying...';
    fetchSurahs();
  }
}
