import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:url_launcher/url_launcher.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';
import '../controllers/revert_controller.dart';

class RevertScreen extends StatelessWidget {
  const RevertScreen({super.key});

  // YouTube video data
  static const List<Map<String, String>> _youtubeVideos = [
    {
      'url': 'https://www.youtube.com/watch?v=tH0Xa1oKVTs',
      'title': 'Revert Story 1',
    },
    {
      'url': 'https://www.youtube.com/watch?v=JINrOTvppuU',
      'title': 'Revert Story 2',
    },
    {
      'url': 'https://www.youtube.com/watch?v=yXCMU72z0Ms',
      'title': 'Revert Story 3',
    },
    {
      'url': 'https://www.youtube.com/watch?v=2zR7R92Trh0',
      'title': 'Revert Story 4',
    },
    {
      'url': 'https://www.youtube.com/watch?v=Sep8rQAwHWE',
      'title': 'Revert Story 5',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final RevertController controller = Get.put(RevertController());
    controller.loadRevertData();

    return Scaffold(
      backgroundColor: AppColors.bgColorThemed(context),
      appBar: AppBar(
        backgroundColor: AppColors.appbarText,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          children: [
            ButtonAnimationWidget(
              child: SvgPicture.asset(
                AppImages.backIcon,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(AppColors.whiteText, BlendMode.srcIn),
              ),
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: easy.tr('revert_convert'),
                    child: Text(
                      easy.tr('welcome'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppColors.whiteText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    easy.tr('guidance'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.whiteText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        final data = controller.revertData.value;

        if (data == null) {
          return Center(child: CircularProgressIndicator(color: AppColors.appbarText));
        }

        return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 40.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    // Text(
                    //   controller.localized(data.title),
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 20,
                    //     fontWeight: FontWeight.w600,
                    //     color: AppColors.blackTextThemed(context),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    for (var section in data.sections) ...[
                      Text(
                        controller.localized(section.sectionTitle),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackTextThemed(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.localized(section.content),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyTextThemed(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Recommended Videos Section
                    const SizedBox(height: 10),
                    Text(
                      'Recommended Videos',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackTextThemed(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildYouTubeLinks(context),
                  ],
                ),
              ),
            ));
      }),
    );
  }

  // Build YouTube video links
  List<Widget> _buildYouTubeLinks(BuildContext context) {
    return _youtubeVideos.map((video) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _openYouTube(context,video['url']!),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.containerColorThemed(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.greyBorderThemed(context),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // YouTube Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                // Video Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['title']!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackTextThemed(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Watch on YouTube',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyTextThemed(context),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.greyTextThemed(context),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // Open YouTube video
  Future<void> _openYouTube(BuildContext context, String url) async {
    final Uri youtubeUri = Uri.parse(url);
    try {
      if (await canLaunchUrl(youtubeUri)) {
        await launchUrl(
          youtubeUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not open YouTube video',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.bgColorThemed(context),
          colorText: AppColors.blackTextThemed(context),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open YouTube: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(context),
        colorText: AppColors.blackTextThemed(context),
        duration: const Duration(seconds: 2),
      );
    }
  }
}
