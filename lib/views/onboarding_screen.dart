import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/controllers/ad_controller.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import 'package:islamlearning/views/goal_screen.dart';
import 'package:islamlearning/views/widgets/location_permission_ads_controller.dart';
import 'package:islamlearning/views/widgets/onboard_ads_controller.dart';

class _OnboardingPage {
  final String image;
  final String titleKey;
  final String subtitleKey;

  const _OnboardingPage({
    required this.image,
    required this.titleKey,
    required this.subtitleKey,
  });
}

// 3 real onboarding pages (index 0, 1, 3 in the PageView)
const _obPages = [
  _OnboardingPage(
    image: AppImages.onboardingPrayer,
    titleKey: 'onboarding_prayer_title',
    subtitleKey: 'onboarding_prayer_subtitle',
  ),
  _OnboardingPage(
    image: AppImages.onboardingQibla,
    titleKey: 'qibla_direction',
    subtitleKey: 'onboarding_qibla_subtitle',
  ),
  _OnboardingPage(
    image: AppImages.onboardingQuran,
    titleKey: 'onboarding_quran_title',
    subtitleKey: 'onboarding_quran_subtitle',
  ),
];

// PageView has 4 pages total:
// index 0 → onboard page 1 (ad below)
// index 1 → onboard page 2 (no ad)
// index 2 → fullscreen native ad page
// index 3 → onboard page 3 (ad below + Start)
const int _kAdPageIndex = 2;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardAdsController _ctrl = Get.find<OnboardAdsController>();
  final AdController _adController = Get.find<AdController>();
  int _currentPage = 0;

  // Computed once — don't show ads or fullscreen ad page for premium users
  late final bool _showAds;
  late final int _totalPages;

  @override
  void initState() {
    super.initState();
    _showAds =
        !_adController.isPremium.value && _adController.nativeEnabled.value;
    _totalPages = _showAds ? 4 : 3; // 4 pages with ad page, 3 without
    Get.put(LocationPermissionAdsController(), permanent: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.off(() => const GoalScreen());
    }
  }

  int get _activeDot {
    if (!_showAds) return _currentPage; // direct 0,1,2 for 3 pages
    if (_currentPage == 0) return 0;
    if (_currentPage == 1) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgColorThemed(context),
        body: SafeArea(
          bottom: false,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _totalPages,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              if (_showAds && index == _kAdPageIndex) {
                return _buildFullscreenAdPage(context);
              }
              // For premium (3 pages): index maps directly 0→0, 1→1, 2→2
              // For free (4 pages): index 0→0, 1→1, skip 2 (ad), 3→2
              final obIndex =
                  (_showAds && index > _kAdPageIndex) ? index - 1 : index;
              return _buildOnboardPage(context, obIndex, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardPage(BuildContext context, int obIndex, int pageIndex) {
    final page = _obPages[obIndex];
    // isLast: for premium last is index 2, for free last is index 3
    final bool isLast = pageIndex == _totalPages - 1;
    // showAd only on first and last page, and only for non-premium
    final bool showBottomAd = _showAds && (pageIndex == 0 || isLast);

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppImages.bgOnboarding, fit: BoxFit.cover),
              Image.asset(page.image, fit: BoxFit.contain),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  easy.tr(page.titleKey),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.appbarText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  easy.tr(page.subtitleKey),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackText(context).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final active = i == _activeDot;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.appbarText
                          : AppColors.appbarText.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appbarText,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLast ? easy.tr('start') : easy.tr('next'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        if (showBottomAd)
          Obx(() {
            // page 0 → ad1, last page (index 3) → ad3
            final isPage0 = pageIndex == 0;
            final ad = isPage0 ? _ctrl.nativeAd1 : _ctrl.nativeAd3;
            final loaded =
                isPage0 ? _ctrl.isAd1Loaded.value : _ctrl.isAd3Loaded.value;
            if (loaded && ad != null) {
              return Container(
                height: 350,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: AdWidget(ad: ad),
              );
            }
            return const SizedBox(height: 350);
          }),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  Widget _buildFullscreenAdPage(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ColoredBox(
            color: const Color(0xFFB2D8D8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Obx(() {
                  if (_ctrl.isAd2Loaded.value &&
                      _ctrl.nativeAdFullscreen != null) {
                    return Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height,
                        child: SizedBox(
                            height: 350,
                            child: AdWidget(ad: _ctrl.nativeAdFullscreen!)));
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }),
                Positioned(
                  top: topPadding + 8,
                  right: 12,
                  child: GestureDetector(
                    onTap: _onNext,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// import 'package:easy_localization/easy_localization.dart' as easy;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:islamlearning/views/constants/appcolors.dart';
// import 'package:islamlearning/views/constants/appimages.dart';
// import 'package:islamlearning/views/goal_screen.dart';
// import 'package:islamlearning/views/widgets/native_ad_widget.dart';

// class _OnboardingPage {
//   final String image;
//   final String titleKey;
//   final String subtitleKey;

//   const _OnboardingPage({
//     required this.image,
//     required this.titleKey,
//     required this.subtitleKey,
//   });
// }

// const _pages = [
//   _OnboardingPage(
//     image: AppImages.onboardingPrayer,
//     titleKey: 'onboarding_prayer_title',
//     subtitleKey: 'onboarding_prayer_subtitle',
//   ),
//   _OnboardingPage(
//     image: AppImages.onboardingQibla,
//     titleKey: 'qibla_direction',
//     subtitleKey: 'onboarding_qibla_subtitle',
//   ),
//   _OnboardingPage(
//     image: AppImages.onboardingQuran,
//     titleKey: 'onboarding_quran_title',
//     subtitleKey: 'onboarding_quran_subtitle',
//   ),
// ];

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onNext() {
//     if (_currentPage < _pages.length - 1) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _onStart();
//     }
//   }

//   Future<void> _onStart() async {
//     Get.off(() => const GoalScreen());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isLast = _currentPage == _pages.length - 1;

//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         backgroundColor: AppColors.bgColorThemed(context),
//         body: SafeArea(
//           bottom: false,
//           child: Column(
//             children: [
//               Expanded(
//                 child: PageView.builder(
//                   controller: _pageController,
//                   itemCount: _pages.length,
//                   onPageChanged: (index) => setState(() => _currentPage = index),
//                   itemBuilder: (context, index) {
//                     return _OnboardingPageView(page: _pages[index]);
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(_pages.length, (i) {
//                         return AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           margin: const EdgeInsets.symmetric(horizontal: 4),
//                           width: _currentPage == i ? 20 : 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: _currentPage == i
//                                 ? AppColors.appbarText
//                                 : AppColors.appbarText.withValues(alpha: 0.3),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         );
//                       }),
//                     ),
//                     const SizedBox(height: 20),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _onNext,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.appbarText,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           isLast ? easy.tr('start') : easy.tr('next'),
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//               // if (_currentPage == 0)
//               //   const NativeAdWidget(key: ValueKey('ob_ad_p1'), templateType: TemplateType.medium, height: 200)
//               // else if (_currentPage == 2)
//               //   const NativeAdWidget(key: ValueKey('ob_ad_p3'), templateType: TemplateType.medium, height: 200)
//               // else
//               //   const SizedBox.shrink(),
//               SizedBox(height: MediaQuery.of(context).padding.bottom),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _OnboardingPageView extends StatelessWidget {
//   final _OnboardingPage page;

//   const _OnboardingPageView({required this.page});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           flex: 6,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.asset(
//                 AppImages.bgOnboarding,
//                 fit: BoxFit.cover,
//               ),
//               Image.asset(
//                 page.image,
//                 fit: BoxFit.contain,
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           flex: 4,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   easy.tr(page.titleKey),
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.appbarText,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   easy.tr(page.subtitleKey),
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     color: AppColors.blackText(context).withValues(alpha: 0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
