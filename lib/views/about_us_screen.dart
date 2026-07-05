import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import '../controllers/about_us_controller.dart';
import 'constants/appcolors.dart';
import 'widgets/animated_button.dart';

class AboutUsScreen extends StatelessWidget {
  AboutUsScreen({super.key});

  final AboutUsController controller = Get.put(AboutUsController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => controller.loadAboutUsData());
    
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
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors.whiteText,
                size: 24,
              ),
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  easy.tr('about_us'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.whiteText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  easy.tr('learn_more_about'),
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
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppColors.appbarText));
        }

        final aboutUsText = controller.getAboutUsText();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // App Logo/Icon Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.containerColorThemed(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greyBorderThemed(context).withValues(alpha:  0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // App Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.appbarText,
                            AppColors.appbarText.withValues(alpha:  0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.appbarText.withValues(alpha:  0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mosque,
                        color: AppColors.buttonText,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // App Name
                    Text(
                      'Muslim Guidance',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.appbarText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Tagline
                    Text(
                      easy.tr('your_complete_islamic_companion'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.greyTextThemed(context),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              
              // About Us Content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.containerColorThemed(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha:  0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.appbarText,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          easy.tr('about_muslim_guidance'),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.appbarText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // About Us Text
                    Text(
                      aboutUsText,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.greyTextThemed(context),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Features Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color:AppColors.containerColorThemed(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha:  0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
                      children: [
                        Icon(
                          Icons.featured_play_list,
                          color: AppColors.appbarText,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          easy.tr('key_features'),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.appbarText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Features List
                    _buildFeatureItem(context, Icons.menu_book, easy.tr('quran_audio_recitation')),
                    _buildFeatureItem(context, Icons.access_time, easy.tr('prayer_times_qibla_direction')),
                    _buildFeatureItem(context, Icons.format_quote, easy.tr('hadith_collection')),
                    _buildFeatureItem(context, Icons.favorite, easy.tr('duas_supplications')),
                    _buildFeatureItem(context, Icons.explore, easy.tr('islamic_knowledge')),
                    _buildFeatureItem(context, Icons.psychology, easy.tr('tasbih_counter')),
                    _buildFeatureItem(context, Icons.quiz, easy.tr('islamic_quiz')),
                    _buildFeatureItem(context, Icons.language, easy.tr('multi_language_support')),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Contact Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.containerColorThemed(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha:  0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
                      children: [
                        Icon(
                          Icons.contact_support,
                          color: AppColors.appbarText,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          easy.tr('get_in_touch'),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.appbarText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Contact Info
                    _buildContactItem(context, Icons.email, easy.tr('email_us_support_feedback')),
                    _buildContactItem(context, Icons.share, easy.tr('share_app_others')),
                    _buildContactItem(context, Icons.star, easy.tr('rate_us_app_store')),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.appbarText.withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.appbarText,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.greyTextThemed(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.appbarText.withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.appbarText,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.greyTextThemed(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

