import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import '../controllers/seerah_controller.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';

class SeerahScreen extends StatelessWidget {
  SeerahScreen({super.key});

  final SeerahController controller =
      Get.put(SeerahController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => controller.loadSeerahData());

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: easy.tr('seerah'),
                    child: Text(
                      easy.tr('prophet_title'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppColors.whiteText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    easy.tr('prophet_subtitle'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.whiteText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        final lang = controller.getLanguageKey();

        if (controller.sections.isEmpty) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.appbarText));
        }

        return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                    // Main sections (always visible)
                    ...controller.sections.map((section) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.sectionTitle[lang] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackTextThemed(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: parseBoldText(
                              section.content[lang] ?? '',
                              normalStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.greyTextThemed(context),
                              ),
                              boldStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackTextThemed(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
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
                        final title = section.sectionTitle[lang] ?? '';
                        final content = section.content[lang] ?? '';

                        return AnimationConfiguration.staggeredList(
                          position:
                              controller.expandableSections.indexOf(section),
                          duration: const Duration(milliseconds: 300),
                          child: SlideAnimation(
                            verticalOffset: 20.0,
                            child: FadeInAnimation(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.containerColorThemed(context),
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
                                    RichText(
                                      text: parseBoldText(
                                        content,
                                        normalStyle: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color:
                                              AppColors.greyTextThemed(context),
                                        ),
                                        boldStyle: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.blackTextThemed(
                                              context),
                                        ),
                                      ),
                                    ),
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
            ));
      }),
    );
  }
}

TextSpan parseBoldText(String text,
    {TextStyle? normalStyle, TextStyle? boldStyle}) {
  final spans = <TextSpan>[];
  final regex = RegExp(r'\*\*(.*?)\*\*'); // matches **bold text**
  int lastMatchEnd = 0;

  for (final match in regex.allMatches(text)) {
    if (match.start > lastMatchEnd) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd, match.start),
        style: normalStyle,
      ));
    }
    spans.add(TextSpan(
      text: match.group(1), // the text inside ** **
      style: boldStyle,
    ));
    lastMatchEnd = match.end;
  }

  if (lastMatchEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastMatchEnd),
      style: normalStyle,
    ));
  }

  return TextSpan(children: spans);
}
