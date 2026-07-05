import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:islamlearning/services/app_review_service.dart';
import 'package:islamlearning/services/local_manager.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import 'package:islamlearning/views/nav_screen.dart';
import 'package:islamlearning/views/widgets/show_location_permission_ad_widget.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _locationEnabled = false;
  bool _loading = false;

  Future<void> _onToggle(bool value) async {
    if (!value || _loading) return;
    setState(() => _loading = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } finally {
      await _finish();
    }
  }

  Future<void> _finish() async {
    await LocaleManager.saveOnboardingCompleted();
    AppReviewService.logHomeLoaded();
    Get.off(() => NavScreen());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgColorThemed(context),
        body: SafeArea(
          child: Column(
            children: [
              /// 🔹 TOP IMAGE (fixed, no Expanded)
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Image.asset(
                    AppImages.bnSplashUpdate,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              /// 🔹 CONTENT (scrollable, no spaceBetween)
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        easy.tr('location_title'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.appbarText,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        easy.tr('location_subtitle'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.blackText(context)
                              .withValues(alpha: 0.55),
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// 🔹 PERMISSION CARD
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.appbarText.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.appbarText
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                AppImages.location,
                                colorFilter: ColorFilter.mode(
                                  AppColors.appbarText,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    easy.tr('location_permission'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    easy.tr('location_permission_desc'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.blackText(context)
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _locationEnabled,
                              onChanged: _loading
                                  ? null
                                  : (v) {
                                      setState(() => _locationEnabled = v);
                                      _onToggle(v);
                                    },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 🔹 SKIP BUTTON
                      TextButton(
                        onPressed: _loading ? null : _finish,
                        child: Text(
                          easy.tr('skip'),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.blackText(context)
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔹 AD (FIXED HEIGHT AREA)
              SizedBox(
                height: 350,
                child: ShowLocationPermissionAdWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
