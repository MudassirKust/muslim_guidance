import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import '../controllers/ruqiyah_controller.dart';
import 'constants/appcolors.dart';
import 'ruqiyah_info_screen.dart';

class RuqiyahScreen extends StatelessWidget {
  final controller = Get.put(RuqiyahController());

  RuqiyahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColorThemed(context),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlayAllControls(context),
                    const SizedBox(height: 20),
                    _buildAudioList(),
                    const SizedBox(height: 80), // Space for bottom player bar
                  ],
                ),
              ),
            ),
            _buildBottomPlayerBar(),
          ],
        );
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.appbarText,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Text(
        easy.tr('ruqiyah_player'),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => Get.to(() => RuqiyahInfoScreen()),
          tooltip: easy.tr('ruqiyah_information'),
        ),
      ],
      elevation: 0,
    );
  }

  Widget _buildPlayAllControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerColorThemed(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorderThemed(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                easy.tr('play_all'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              Obx(() => ElevatedButton.icon(
                    onPressed: () {
                      if (controller.isPlayAllMode.value) {
                        controller.stopPlayAll();
                      } else {
                        controller.startPlayAll();
                      }
                    },
                    icon: Icon(
                      controller.isPlayAllMode.value
                          ? Icons.stop
                          : Icons.play_arrow,
                      size: 20,
                    ),
                    label: Text(
                      controller.isPlayAllMode.value
                          ? easy.tr('stop_all')
                          : easy.tr('play_all'),
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isPlayAllMode.value
                          ? AppColors.wrongOption
                          : AppColors.appbarText,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  )),
            ],
          ),
          Obx(() {
            if (controller.isPlayAllMode.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.playlist_play,
                        color: AppColors.appbarText, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${easy.tr('now_playing')}: ${controller.audios[controller.currentPlayAllIndex.value].titleEnglish} (${controller.currentReplayIteration.value + 1}/${controller.replayCounts[controller.audios[controller.currentPlayAllIndex.value].id] ?? 1})',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.greyTextThemed(context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildAudioList() {
    return Obx(() => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.audios.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final audio = controller.audios[index];
            return _buildAudioCard(context, audio, index);
          },
        ));
  }

  Widget _buildAudioCard(BuildContext context, audio, int index) {
    return Obx(() {
      final isPlaying = controller.currentlyPlayingIndex.value == index &&
          controller.isPlaying.value;
      final isLoading = controller.audioLoadingIndex.value == index;
      final isDownloaded = controller.downloadStatus[audio.id] ?? false;
      final isDownloading = controller.isDownloading[audio.id] ?? false;
      final downloadProgressValue =
          controller.downloadProgress[audio.id] ?? 0.0;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.containerColorThemed(context)
              : AppColors.containerColorThemed(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPlaying
                ? AppColors.appbarText
                : AppColors.greyBorderThemed(context),
            width: isPlaying ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arabic and English titles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audio.titleEnglish,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackTextThemed(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        audio.titleArabic,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.greyTextThemed(context),
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Play/Pause button
                IconButton(
                  onPressed: isLoading
                      ? null
                      : () => controller.togglePlayPause(index),
                  icon: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 40,
                          color: AppColors.appbarText,
                        ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              easy.tr(audio.descriptionKey),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.greyTextThemed(context),
              ),
            ),

            const SizedBox(height: 12),

            // Replay counter selector
            _buildReplayCounter(context, audio.id),

            const SizedBox(height: 12),

            // Download button and progress
            Row(
              children: [
                Expanded(
                  child: isDownloading
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Downloading...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.greyTextThemed(context),
                                  ),
                                ),
                                Text(
                                  '${(downloadProgressValue * 100).toInt()}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.appbarText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: downloadProgressValue,
                              backgroundColor:
                                  AppColors.greyBorderThemed(context),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.appbarText),
                            ),
                          ],
                        )
                      : OutlinedButton.icon(
                          onPressed: () {
                            if (isDownloaded) {
                              _showDeleteDialog(audio.id, audio.titleEnglish);
                            } else {
                              controller.downloadAudio(audio.id);
                            }
                          },
                          icon: Icon(
                            isDownloaded ? Icons.check_circle : Icons.download,
                            size: 18,
                            color: isDownloaded
                                ? AppColors.correctOption
                                : AppColors.appbarText,
                          ),
                          label: Text(
                            isDownloaded ? 'Downloaded' : 'Download',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDownloaded
                                ? AppColors.correctOption
                                : AppColors.appbarText,
                            side: BorderSide(
                              color: isDownloaded
                                  ? AppColors.correctOption
                                  : AppColors.appbarText,
                            ),
                          ),
                        ),
                ),
              ],
            ),

            // Progress bar (when playing)
            if (isPlaying)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: controller.currentProgress.value,
                      backgroundColor: AppColors.greyBorderThemed(context),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.appbarText),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.currentDuration.value,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.greyTextThemed(context),
                          ),
                        ),
                        Text(
                          controller.totalDuration.value,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.greyTextThemed(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildReplayCounter(BuildContext context, int audioId) {
    return Obx(() {
      final currentCount = controller.replayCounts[audioId] ?? 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${easy.tr('replay_count')}: ${currentCount}x',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.blackTextThemed(context),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(10, (index) {
              final count = index + 1;
              final isSelected = currentCount == count;
              return GestureDetector(
                onTap: () => controller.updateReplayCount(audioId, count),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.appbarText
                        : AppColors.containerColorThemed(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.appbarText
                          : AppColors.greyBorderThemed(context),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: GoogleFonts.poppins(
                        color: isSelected
                            ? Colors.white
                            : AppColors.blackTextThemed(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }

  Widget _buildBottomPlayerBar() {
    return Obx(() {
      if (!controller.isPlaying.value) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.appbarText,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: controller.currentlyPlayingIndex.value > 0
                  ? () => controller.playPrevious()
                  : null,
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              iconSize: 32,
            ),
            IconButton(
              onPressed: () {
                if (controller.isPlaying.value) {
                  controller.audioPlayer.pause();
                } else {
                  controller.audioPlayer.play();
                }
              },
              icon: Icon(
                controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              iconSize: 36,
            ),
            IconButton(
              onPressed: controller.currentlyPlayingIndex.value <
                      controller.audios.length - 1
                  ? () => controller.playNext()
                  : null,
              icon: const Icon(Icons.skip_next, color: Colors.white),
              iconSize: 32,
            ),
            IconButton(
              onPressed: () => controller.toggleMute(),
              icon: Icon(
                controller.isMuted.value ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
              iconSize: 28,
            ),
          ],
        ),
      );
    });
  }

  void _showDeleteDialog(int audioId, String title) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete Download?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Do you want to remove $title from offline storage?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              controller.deleteAudio(audioId);
              Get.back();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppColors.wrongOption),
            ),
          ),
        ],
      ),
    );
  }
}
