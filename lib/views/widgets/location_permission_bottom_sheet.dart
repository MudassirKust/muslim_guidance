import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/services/permission_coordinator.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import 'package:islamlearning/views/widgets/native_ad_widget.dart';

void showLocationPermissionBottomSheet(
  BuildContext context, {
  required VoidCallback onPermissionGranted,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.bgColorThemed(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _LocationPermissionSheet(onPermissionGranted: onPermissionGranted),
  );
}

class _LocationPermissionSheet extends StatefulWidget {
  final VoidCallback onPermissionGranted;

  const _LocationPermissionSheet({required this.onPermissionGranted});

  @override
  State<_LocationPermissionSheet> createState() => _LocationPermissionSheetState();
}

class _LocationPermissionSheetState extends State<_LocationPermissionSheet> {
  bool _locationEnabled = false;
  bool _loading = false;

  Future<void> _onToggle(bool value) async {
    if (!value || _loading) return;
    setState(() => _loading = true);

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await PermissionCoordinator().run(() => Geolocator.requestPermission());
      }

      if (!mounted) return;

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Navigator.of(context).pop();
        widget.onPermissionGranted();
      } else if (permission == LocationPermission.deniedForever) {
        Navigator.of(context).pop();
        await Geolocator.openAppSettings();
      } else {
        // Still denied — reset toggle and close sheet
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.blackText(context).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                AppImages.bnSplashUpdate,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  easy.tr('location_title'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.appbarText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  easy.tr('location_subtitle'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackText(context).withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.appbarText.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.appbarText.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(9),
                        child: SvgPicture.asset(
                          AppImages.location,
                          colorFilter: ColorFilter.mode(
                            AppColors.appbarText,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              easy.tr('location_permission'),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackText(context),
                              ),
                            ),
                            Text(
                              easy.tr('location_permission_desc'),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blackText(context).withValues(alpha: 0.55),
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
                        activeThumbColor: AppColors.appbarText,
                        activeTrackColor: AppColors.appbarText.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const NativeAdWidget(height: 80),
        ],
      ),
    );
  }
}