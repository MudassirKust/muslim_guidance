import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/services/app_review_service.dart';
import 'package:islamlearning/services/local_manager.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import 'package:islamlearning/views/location_permission_screen.dart';
import 'package:islamlearning/views/nav_screen.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final Set<int> _selected = {};

  Future<void> _finish() async {
    await LocaleManager.saveOnboardingCompleted();
    AppReviewService.logHomeLoaded();
    Get.off(() => NavScreen());
  }

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgColorThemed(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: Image.asset(AppImages.appIconPNG),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          easy.tr('goal_title'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.appbarText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          easy.tr('goal_subtitle'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.blackText(context).withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _FeatureItem(icon: AppImages.icPrayerReminder, label: easy.tr('prayer_reminder'), selected: _selected.contains(0), onTap: () => _toggle(0)),
                        const SizedBox(height: 12),
                        _FeatureItem(icon: AppImages.icQuran, label: easy.tr('quran'), selected: _selected.contains(1), onTap: () => _toggle(1)),
                        const SizedBox(height: 12),
                        _FeatureItem(icon: AppImages.icIslam, label: easy.tr('learn_islam'), selected: _selected.contains(2), onTap: () => _toggle(2)),
                        const SizedBox(height: 12),
                        _FeatureItem(icon: AppImages.icQuiz, label: easy.tr('test_yourself'), selected: _selected.contains(3), onTap: () => _toggle(3)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selected.isEmpty
                        ? null
                        : () => Get.off(() => const LocationPermissionScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appbarText,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.appbarText.withValues(alpha: 0.3),
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      easy.tr('get_started'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _finish,
                  child: Text(
                    easy.tr('skip_tour'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackText(context).withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = selected ? AppColors.appbarText : AppColors.appbarText.withValues(alpha: 0.07);
    final Color contentColor = selected ? Colors.black : AppColors.appbarText;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  icon,
                  colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: contentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}