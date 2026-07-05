import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/controllers/auth_controller.dart';
import 'package:islamlearning/views/constants/appcolors.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.bgColor(context),
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.premiumGradientStart,
                  AppColors.premiumGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    // Back button row
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.whiteText,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SvgPicture.asset(
                      'assets/images/ic_mosque.svg',
                      width: 56,
                      height: 56,
                      colorFilter: const ColorFilter.mode(
                        AppColors.whiteText,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Muslim Guidance',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: AppColors.whiteText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your journey to premium starts here',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create an account',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.blackText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to unlock premium features and enjoy an ad-free experience.',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.greyText(context),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _BenefitRow(
                    icon: Icons.block_rounded,
                    title: 'Ad-Free Premium',
                    subtitle: 'Uninterrupted worship. No distractions.',
                  ),
                  const SizedBox(height: 12),
                  _BenefitRow(
                    icon: Icons.translate_rounded,
                    title: 'Quran in 45+ Languages',
                    subtitle: "Understand Allah's message in your native tongue.",
                  ),
                  const SizedBox(height: 12),
                  _BenefitRow(
                    icon: Icons.self_improvement_rounded,
                    title: 'Full Ruqyah Healing',
                    subtitle: 'Authentic audio for protection and spiritual cure.',
                  ),
                  const SizedBox(height: 12),
                  _BenefitRow(
                    icon: Icons.quiz_rounded,
                    title: 'Islamic Knowledge Quizzes',
                    subtitle: 'Master the Quran, History, and Seerah.',
                  ),
                  const SizedBox(height: 24),

                  // Google Sign-In Button
                  Obx(() => GestureDetector(
                        onTap: authController.isLoading.value
                            ? null
                            : authController.signInWithGoogle,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.containerColor(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.greyBorder(context),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: authController.isLoading.value
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.appbarText,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/ic_google.svg',
                                      width: 22,
                                      height: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: AppColors.blackText(context),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      )),

                  const SizedBox(height: 24),

                  // Terms note
                  Center(
                    child: Text(
                      'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: AppColors.greyText(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.appbarText.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.appbarText,
            size: 18,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.blackText(context),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.greyText(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}