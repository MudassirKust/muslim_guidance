import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../constants/quran_editions.dart';
import '../controllers/surah_detail_controller.dart';
import 'constants/appimages.dart';

class SurahDetailScreen extends StatelessWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  void _showLanguageSelector(
      BuildContext context, SurahDetailController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgColorThemed(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        final editions = QuranEditions.defaultEditions;
        final labels = QuranEditions.languageLabels;
        final keys = editions.keys.toList();

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Select Translation',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackTextThemed(context),
                    ),
                  ),
                ),
                Divider(color: AppColors.greyBorderThemed(context), height: 1),
                Obx(() {
                  if (controller.shouldLoadTranslation) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_outline,
                              color: Colors.white),
                          label: Text(
                            'Watch Ad to Unlock All Translations for 24h',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                                ctx); // Close modal before full-screen ad
                            controller.watchAdForTranslationUnlock();
                          },
                        ),
                      ),
                      Divider(
                          color: AppColors.greyBorderThemed(context),
                          height: 1),
                    ],
                  );
                }),
                Expanded(
                  child: Obx(() {
                    final current = controller.selectedEdition.value;
                    return ListView.builder(
                      controller: scrollCtrl,
                      itemCount: keys.length,
                      itemBuilder: (_, i) {
                        final lang = keys[i];
                        final edition = editions[lang]!;
                        final label = labels[lang] ?? lang.toUpperCase();
                        final isSelected = edition == current;

                        return ListTile(
                          onTap: () {
                            Navigator.pop(ctx);
                            controller.changeEdition(edition);
                          },
                          title: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.appbarText
                                  : AppColors.blackTextThemed(context),
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check,
                                  color: AppColors.appbarText, size: 18)
                              : null,
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDownloadDialog(
      BuildContext context, SurahDetailController controller) async {
    final isDownloaded = await controller.storageService
        .isSurahDownloaded(controller.surahNumber);

    if (isDownloaded) {
      // Show delete confirmation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.bgColorThemed(context),
          title: Center(
            child: Text(
              'Delete Offline Surah?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackTextThemed(context),
              ),
            ),
          ),
          content: Text(
            'This will remove ${controller.surahData['name']} from offline storage. You can download it again later.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.greyTextThemed(context),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.containerColorThemed(context),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackTextThemed(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.deleteSurah();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Show download confirmation
      final estimatedSize =
          await controller.storageService.getEstimatedSize(controller.verses);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.bgColorThemed(context),
          title: Center(
            child: Text(
              'Download for Offline?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackTextThemed(context),
              ),
            ),
          ),
          content: Text(
            'Download ${controller.surahData['name']} (${estimatedSize.toStringAsFixed(1)} MB) for offline listening?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.greyTextThemed(context),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.containerColorThemed(context),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackTextThemed(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.downloadSurah();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Download',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackTextThemed(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SurahDetailController(surahNumber));
    return Scaffold(
      backgroundColor: AppColors.bgColorThemed(context),
      body: SafeArea(
        child: Column(
          children: [
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
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: SvgPicture.asset(AppImages.backIcon)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.surahData['name'] ?? 'Surah',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: AppColors.appbarText,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  controller.surahData['nameArabic'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: AppColors.greyTextThemed(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(() {
                            final hasAccess = controller.shouldLoadTranslation;
                            return GestureDetector(
                              onTap: () {
                                // Always open the language selector —
                                // the "Watch Ad to Unlock" banner inside handles
                                // non-premium / non-unlocked users.
                                _showLanguageSelector(context, controller);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.appbarText, width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasAccess)
                                      Text(
                                        QuranEditions.shortCodeForEdition(
                                            controller.selectedEdition.value),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.appbarText,
                                        ),
                                      )
                                    else
                                      Icon(Icons.lock,
                                          color: AppColors.appbarText,
                                          size: 14),
                                    const SizedBox(width: 2),
                                    Icon(Icons.arrow_drop_down,
                                        color: AppColors.appbarText, size: 16),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      Obx(() {
                        if (controller.shouldLoadTranslation)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_circle_outline,
                                color: Colors.white, size: 18),
                            label: Text(
                              'Watch Ad to Unlock Translations (24h)',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonColor,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: controller.watchAdForTranslationUnlock,
                          ),
                        );
                      }),
                      Expanded(
                        child: Obx(() => Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  border: Border.all(
                                      color:
                                          AppColors.greyBorderThemed(context),
                                      width: 1)),
                              child: ScrollablePositionedList.builder(
                                  itemScrollController:
                                      controller.itemScrollController,
                                  itemCount: controller.verses.length,
                                  //padding: const EdgeInsets.all(16),
                                  itemBuilder: (context, index) {
                                    final verse = controller.verses[index];

                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 50),
                                      child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: Obx(() {
                                            final isCurrent = controller
                                                    .currentlyPlayingIndex
                                                    .value ==
                                                index;
                                            // final isPlaying =
                                            //     controller.isPlaying.value &&
                                            //         isCurrent;

                                            return Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isCurrent
                                                    ? AppColors.containerColor(
                                                        context)
                                                    : AppColors.bgColor(
                                                        context),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: isCurrent
                                                    ? Border.all(
                                                        color: AppColors
                                                            .appbarText,
                                                        width: 1)
                                                    : Border.all(
                                                        color:
                                                            Colors.transparent),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isCurrent
                                                              ? Colors
                                                                  .transparent
                                                              : const Color(
                                                                  0xffF8F3E1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                        ),
                                                        child: Text(
                                                          '${controller.surahData['number']}:${verse['number']}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
                                                            color: isCurrent
                                                                ? AppColors
                                                                    .greenTeal
                                                                : AppColors
                                                                    .darkMintGreen,
                                                          ),
                                                        ),
                                                      ),
                                                      Obx(() {
                                                        final isCurrentVerse =
                                                            controller
                                                                    .currentlyPlayingIndex
                                                                    .value ==
                                                                index;
                                                        final isPlaying =
                                                            controller.isPlaying
                                                                    .value &&
                                                                isCurrentVerse;
                                                        final isLoading = controller
                                                                .isAudioLoading
                                                                .value &&
                                                            controller
                                                                    .audioLoadingIndex
                                                                    .value ==
                                                                index;

                                                        if (isLoading) {
                                                          return SizedBox(
                                                            height: 16,
                                                            width: 16,
                                                            child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: AppColors
                                                                    .appbarText),
                                                          );
                                                        }

                                                        final isAnotherVerseLoading =
                                                            controller
                                                                    .isAudioLoading
                                                                    .value &&
                                                                controller
                                                                        .audioLoadingIndex
                                                                        .value !=
                                                                    index;

                                                        if (isAnotherVerseLoading &&
                                                            isCurrentVerse) {
                                                          return SvgPicture
                                                              .asset(
                                                            AppImages.play,
                                                            color: AppColors
                                                                .buttonColor,
                                                          );
                                                        }

                                                        return InkWell(
                                                          onTap: () => controller
                                                              .togglePlayPause(
                                                                  index),
                                                          child:
                                                              SvgPicture.asset(
                                                            isPlaying
                                                                ? AppImages
                                                                    .pause
                                                                : AppImages
                                                                    .play,
                                                            color: AppColors
                                                                .buttonColor,
                                                          ),
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    verse['text'] ?? '',
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 20,
                                                      fontWeight: isCurrent
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color:
                                                          AppColors.blackText(
                                                              context),
                                                    ),
                                                  ),
                                                  if (controller
                                                          .isTranslationVisible
                                                          .value &&
                                                      controller
                                                          .shouldLoadTranslation &&
                                                      verse['translation'] !=
                                                          null &&
                                                      (verse['translation']
                                                              as String)
                                                          .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: SizedBox(
                                                        width: double.infinity,
                                                        child: Directionality(
                                                          textDirection: QuranEditions
                                                                  .isRtlEdition(
                                                                      controller
                                                                          .selectedEdition
                                                                          .value)
                                                              ? TextDirection
                                                                  .rtl
                                                              : TextDirection
                                                                  .ltr,
                                                          child: Text(
                                                            verse[
                                                                'translation'],
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .greyTextThemed(
                                                                      context),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  const SizedBox(height: 10),
                                                  Divider(
                                                      color: isCurrent
                                                          ? Colors.white
                                                          : Colors.grey),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  }),
                            )),
                      ),
                      Obx(() {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.containerColorThemed(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                  onTap: () {
                                    controller.currentlyPlayingIndex.value <= 0
                                        ? null
                                        : controller.playPreviousVerse();
                                  },
                                  child: SvgPicture.asset(
                                    AppImages.previous,
                                    color: controller
                                                .currentlyPlayingIndex.value <=
                                            0
                                        ? AppColors.greyText(context)
                                        : AppColors.iconColor(context),
                                  )),
                              Obx(() {
                                final isLoading =
                                    controller.isAudioLoading.value;
                                final isPlaying = controller.isPlaying.value;

                                if (isLoading) {
                                  return SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.iconColorThemed(context),
                                    ),
                                  );
                                }

                                return InkWell(
                                  onTap: () {
                                    controller.toggleTopPlayPause();
                                  },
                                  child: SvgPicture.asset(
                                    isPlaying
                                        ? AppImages.pause
                                        : AppImages.play,
                                    color: AppColors.iconColorThemed(context),
                                  ),
                                );
                              }),
                              InkWell(
                                  onTap: () {
                                    controller.currentlyPlayingIndex.value >=
                                            controller.verses.length - 1
                                        ? null
                                        : controller.playNextVerse();
                                  },
                                  child: SvgPicture.asset(
                                    AppImages.next,
                                    color: controller
                                                .currentlyPlayingIndex.value >=
                                            controller.verses.length - 1
                                        ? AppColors.greyText(context)
                                        : AppColors.iconColor(context),
                                  )),
                              Obx(() {
                                if (controller.isDownloading.value) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          // Show indeterminate spinner when progress is 0 or very small
                                          // Show determinate progress when we have actual progress
                                          value: controller
                                                      .downloadProgress.value >
                                                  0.01
                                              ? controller
                                                  .downloadProgress.value
                                              : null,
                                          strokeWidth: 2,
                                          color: AppColors.iconColorThemed(
                                              context),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return InkWell(
                                  onTap: () {
                                    _showDownloadDialog(context, controller);
                                  },
                                  child: SvgPicture.asset(
                                    controller.isOfflineMode.value
                                        ? AppImages.download
                                        : AppImages.download,
                                    color: controller.isOfflineMode.value
                                        ? Colors.green
                                        : AppColors.iconColor(context),
                                  ),
                                );
                              }),
                              InkWell(
                                  onTap: () {
                                    controller.toggleMute();
                                  },
                                  child: SvgPicture.asset(
                                    AppImages.speaker,
                                    color: AppColors.iconColorThemed(context),
                                  )),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
