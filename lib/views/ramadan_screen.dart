import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import '../controllers/ramadan_controller.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';

class RamadanScreen extends StatelessWidget {
  RamadanScreen({super.key});

  final RamadanController controller =
      Get.put(RamadanController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => controller.loadRamadanData());
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
                colorFilter:
                    ColorFilter.mode(AppColors.whiteText, BlendMode.srcIn),
              ),
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: easy.tr('ramadan'),
                  child: Text(
                    easy.tr('ramadan'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.whiteText,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  easy.tr('complete_guide_to_ramadan'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.whiteText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Obx(() {
        final lang = controller.getLanguageKey();

        if (controller.regularSections.isEmpty &&
            controller.expandableSections.isEmpty) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.appbarText));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Regular Sections
                ...controller.regularSections.map((section) {
                  final title = section.sectionTitle[lang] ??
                      section.sectionTitle['en'] ??
                      '';
                  final content =
                      section.content[lang] ?? section.content['en'] ?? '';

                  return AnimationConfiguration.staggeredList(
                    position: controller.regularSections.indexOf(section),
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 40.0,
                      child: FadeInAnimation(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.appbarText,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildFormattedContent(context, content),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Read More Button for Additional Content
                if (controller.expandableSections.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.toggleAllSections(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appbarText,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.isAllExpanded.value
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.isAllExpanded.value
                                ? easy.tr('show_less')
                                : easy.tr('read_more'),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // All Expandable Content (shown when expanded)
                if (controller.isAllExpanded.value) ...[
                  ...controller.expandableSections.map((section) {
                    final title = section.sectionTitle[lang] ??
                        section.sectionTitle['en'] ??
                        '';
                    final content =
                        section.content[lang] ?? section.content['en'] ?? '';

                    return AnimationConfiguration.staggeredList(
                      position: controller.expandableSections.indexOf(section),
                      duration: const Duration(milliseconds: 300),
                      child: SlideAnimation(
                        verticalOffset: 20.0,
                        child: FadeInAnimation(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.containerColorThemed(context),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.greyBorderThemed(context)
                                      .withValues(alpha: 0.1),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.appbarText,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildFormattedContent(context, content),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFormattedContent(BuildContext context, String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Check if this is a table row (contains |)
      if (line.contains('|')) {
        widgets.add(_buildTableRow(context, line));
        continue;
      }

      // Check if this is a bullet point
      if (line.startsWith('- ')) {
        widgets.add(_buildBulletPoint(context, line.substring(2)));
        continue;
      }

      // Check if this is a numbered item (A., B., C., etc.)
      if (RegExp(r'^[A-Z]\.\s').hasMatch(line)) {
        widgets.add(_buildNumberedItem(context, line));
        continue;
      }

      // Regular text
      widgets.add(
        Text(
          line,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.greyTextThemed(context),
            height: 1.6,
          ),
        ),
      );

      if (i < lines.length - 1) {
        widgets.add(const SizedBox(height: 4));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildTableRow(BuildContext context, String line) {
    final cells = line
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.greyTextThemed(context).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: AppColors.greyTextThemed(context).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: cells
            .map((cell) => Expanded(
                  child: Text(
                    cell,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyTextThemed(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.appbarText,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.greyTextThemed(context),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(BuildContext context, String line) {
    final parts = line.split('. ');
    if (parts.length < 2) return Text(line);

    final number = parts[0];
    final text = parts.sublist(1).join('. ');

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 8),
            child: Text(
              '$number.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.appbarText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.greyTextThemed(context),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
