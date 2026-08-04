import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/views/juz_detail.dart';
import 'package:islamlearning/views/surah_detail.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import '../controllers/audio_controller.dart';
import '../models/juz_model.dart';
import '../services/surah_storage_service.dart';
import 'constants/appcolors.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioController controller = Get.put(AudioController());
  final storageService = SurahStorageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleSurahTap(
      BuildContext context, int surahNumber, String surahName) async {
    final isDownloaded = await storageService.isSurahDownloaded(surahNumber);
    final hasInternet = await _hasInternetConnection();

    if (isDownloaded || hasInternet) {
      Get.to(() => SurahDetailScreen(surahNumber: surahNumber))
          ?.then((_) => controller.refreshLastRead());
    } else {
      if (!context.mounted) return;
      Get.snackbar(
        'Surah Not Downloaded',
        'This Surah is not available offline. Please connect to internet and download this Surah to make it available when offline.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(context),
        colorText: AppColors.blackTextThemed(context),
        duration: const Duration(seconds: 4),
      );
    }
  }

  Widget _buildContinueReadingCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: TouchRippleEffect(
        borderRadius: BorderRadius.circular(12),
        rippleColor: Colors.grey,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.containerColorThemed(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.appbarText, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.bookmark, color: AppColors.appbarText, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue Reading',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.appbarText,
                      ),
                    ),
                    Text(
                      '$title · $subtitle',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.greyTextThemed(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: AppColors.appbarText, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahTab(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.appbarText),
                    const SizedBox(height: 10),
                    Center(
                      child: Obx(() => Text(
                            controller.loadingStep.value,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: AppColors.appbarText,
                            ),
                          )),
                    )
                  ],
                );
              }

              if (controller.error.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(controller.error.value),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.retry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: AppColors.greyTextThemed(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Continue reading card for Surah mode
                  Obx(() {
                    final last = controller.lastReadSurah.value;
                    if (last == null) return const SizedBox.shrink();
                    return _buildContinueReadingCard(
                      context: context,
                      title: last['surahName'] as String? ?? '',
                      subtitle:
                          'Verse ${(last['verseIndex'] as int? ?? 0) + 1}',
                      onTap: () => Get.to(
                        () => SurahDetailScreen(
                            surahNumber: last['surahNumber'] as int),
                      )?.then((_) => controller.refreshLastRead()),
                    );
                  }),
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        itemCount: controller.surahs.length,
                        itemBuilder: (context, index) {
                          final surah = controller.surahs[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: TouchRippleEffect(
                                  borderRadius: BorderRadius.circular(10),
                                  rippleColor: Colors.grey,
                                  onTap: () {
                                    _handleSurahTap(
                                      context,
                                      int.parse(surah['number'].toString()),
                                      surah['name']?.toString() ?? 'Unknown',
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .containerColorThemed(
                                                        context),
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  surah['number']?.toString() ??
                                                      '',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 17,
                                                    color: AppColors.indexColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  surah['name']?.toString() ??
                                                      'Unknown',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    color: AppColors
                                                        .blackTextThemed(
                                                            context),
                                                  ),
                                                ),
                                                const SizedBox(height: 7),
                                                Text(
                                                  '${surah['location']?.toString() ?? ''}-${surah['verses']?.toString() ?? ''}',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 10,
                                                    color: AppColors
                                                        .greyTextThemed(
                                                            context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          surah['nameUrdu']?.toString() ?? '',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: AppColors.appbarText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildParahTab(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          // Continue reading card for Parah mode
          Obx(() {
            final last = controller.lastReadParah.value;
            if (last == null) return const SizedBox.shrink();
            return _buildContinueReadingCard(
              context: context,
              title: last['commonName'] as String? ?? '',
              subtitle: 'Verse ${(last['verseIndex'] as int? ?? 0) + 1}',
              onTap: () => Get.to(
                () => JuzDetailScreen(juzNumber: last['juzNumber'] as int),
              )?.then((_) => controller.refreshLastRead()),
            );
          }),
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: ParahInfo.all.length,
                itemBuilder: (context, index) {
                  final parah = ParahInfo.all[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: TouchRippleEffect(
                          borderRadius: BorderRadius.circular(10),
                          rippleColor: Colors.grey,
                          onTap: () {
                            Get.to(() =>
                                    JuzDetailScreen(juzNumber: parah.number))
                                ?.then((_) => controller.refreshLastRead());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.containerColorThemed(
                                            context),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${parah.number}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                            color: AppColors.indexColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          parah.commonName,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: AppColors.blackTextThemed(
                                                context),
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          'Starts: ${parah.startSurahName} ${parah.startAyah > 1 ? ':${parah.startAyah}' : ''}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10,
                                            color: AppColors.greyTextThemed(
                                                context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  parah.arabicName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: AppColors.appbarText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColorThemed(context),
      appBar: AppBar(
        backgroundColor: AppColors.bgColorThemed(context),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              easy.tr('audio_quran'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.appbarText,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              easy.tr('audio_quran_desc'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.greyTextThemed(context),
              ),
              maxLines: 2,
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.appbarText,
          labelColor: AppColors.appbarText,
          unselectedLabelColor: AppColors.greyTextThemed(context),
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Surah'),
            Tab(text: 'Parah'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSurahTab(context),
          _buildParahTab(context),
        ],
      ),
    );
  }
}
