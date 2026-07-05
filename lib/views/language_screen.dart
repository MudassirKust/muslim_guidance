import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/views/widgets/language_ads_controller.dart';
import 'package:islamlearning/views/widgets/native_ad_second_widget.dart';
import '../controllers/settings_controller.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'onboarding_screen.dart';
import 'widgets/animated_button.dart';
import 'widgets/show_onboard_native_language_widget.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen(
      {super.key, this.isOnboarding = false, this.isOnboardComplete = true});
  final bool isOnboarding;
  final bool isOnboardComplete;
  SettingsController get controller => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColorThemed(context),
      appBar: AppBar(
        backgroundColor: AppColors.appbarText,
        toolbarHeight: 80,
        title: Row(
          children: [
            if (!isOnboarding)
              ButtonAnimationWidget(
                child: SvgPicture.asset(
                  AppImages.backIcon,
                  height: 24,
                  width: 24,
                  colorFilter:
                      ColorFilter.mode(AppColors.whiteText, BlendMode.srcIn),
                ),
                onTap: () {
                  Get.back();
                },
              )
            else
              const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    easy.tr('language'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.whiteText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    // overflow: TextOverflow.ellipsis,
                    easy.tr('choose_language'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.whiteText,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (!isOnboardComplete)
            Obx(() {
              final hasSelection =
                  controller.hasExplicitlySelectedLanguage.value;
              return !hasSelection
                  ? SizedBox()
                  : GestureDetector(
                      onTap: hasSelection
                          ? () async {
                              await context.setLocale(
                                controller.currentLocale.value,
                              );

                              if (context.mounted) {
                                Get.off(() => const OnboardingScreen());
                              }
                            }
                          : () {
                              Get.snackbar(
                                'Language Required',
                                'Please choose a language first.',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                              );
                            },
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(
                            easy.tr('next'),
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    );
            }),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(() {
                final langEntries = controller.languageMap.entries.toList();
                final currentLangName = langEntries
                    .firstWhere(
                      (entry) => entry.value == controller.currentLocale.value,
                      orElse: () => const MapEntry('English', Locale('en')),
                    )
                    .key;
                final hasSelection =
                    controller.hasExplicitlySelectedLanguage.value;

                return AnimationLimiter(
                  child: ListView.separated(
                    itemCount: langEntries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = langEntries[index];
                      final isSelected =
                          hasSelection && currentLangName == entry.key;
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        delay: const Duration(milliseconds: 100),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          duration: const Duration(milliseconds: 400),
                          child: FadeInAnimation(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              title: Text(entry.key),
                              trailing: isSelected
                                  ? Icon(Icons.radio_button_checked,
                                      color: AppColors.appbarText)
                                  : Icon(Icons.radio_button_off,
                                      color: AppColors.navbarText),
                              onTap: () async {
                                // Sync GetX state first: GetMaterialApp builds
                                // with `Get.locale ?? locale`, so Get.locale
                                // must already hold the new value when
                                // easy_localization's setLocale triggers the
                                // app-level rebuild.
                                await controller.changeLanguage(entry.value);
                                if (context.mounted) {
                                  await context.setLocale(entry.value);
                                }
                                final controller2 =
                                    Get.find<LanguageAdsController>();
                                controller2.showSecondAd();
                                // if (context.mounted &&
                                //     entry.value.languageCode == 'en') {
                                //   await FullScreenNativeAdOverlay.show(context);
                                // }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
            // if (isOnboarding) ...[
            //   Obx(() {
            //     final hasSelection =
            //         controller.hasExplicitlySelectedLanguage.value;

            //     return SizedBox(
            //       width: double.infinity,
            //       child: ElevatedButton(
            //         onPressed: hasSelection
            //             ? () async {
            //                 await context.setLocale(
            //                   controller.currentLocale.value,
            //                 );

            //                 if (context.mounted) {
            //                   Get.off(() => const OnboardingScreen());
            //                 }
            //               }
            //             : () {
            //                 Get.snackbar(
            //                   'Language Required',
            //                   'Please choose a language first.',
            //                   snackPosition: SnackPosition.BOTTOM,
            //                   duration: const Duration(seconds: 2),
            //                 );
            //               },
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor:
            //               hasSelection ? AppColors.appbarText : Colors.grey,
            //           foregroundColor: AppColors.whiteText,
            //           padding: const EdgeInsets.symmetric(vertical: 16),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //         child: Text(
            //           easy.tr('next'),
            //           style: GoogleFonts.poppins(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     );
            //   }),
            //   const SizedBox(height: 16),
            // ],
            // if (isOnboarding) ...[
            //   SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       onPressed: () async {
            //         await context.setLocale(controller.currentLocale.value);
            //         if (context.mounted) {
            //           Get.off(() => const OnboardingScreen());
            //         }
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: AppColors.appbarText,
            //         foregroundColor: AppColors.whiteText,
            //         padding: const EdgeInsets.symmetric(vertical: 16),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //       ),
            //       child: Text(
            //         easy.tr('continue'),
            //         style: GoogleFonts.poppins(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ),
            //   ),
            //   const SizedBox(height: 16),
            // ],
            if (isOnboardComplete) ...[
              NativeAdSecondWidget(
                  templateType: TemplateType.small, height: 280),
            ] else ...[
              ShowOnboardNativeLanguageWidget(),
            ],
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
