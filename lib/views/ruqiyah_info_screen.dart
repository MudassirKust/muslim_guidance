import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'constants/appcolors.dart';

class RuqiyahInfoScreen extends StatelessWidget {
  const RuqiyahInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColorThemed(context),
      appBar: AppBar(
        backgroundColor: AppColors.appbarText,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          easy.tr('ruqiyah_information'),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: easy.tr('ruqiyah_intro_title'),
              content: easy.tr('ruqiyah_intro_content'),
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: easy.tr('ruqiyah_how_to_use_title'),
              content: easy.tr('ruqiyah_how_to_use_content'),
            ),
            const SizedBox(height: 20),
            _buildComprehensiveGuidelines(context),
            const SizedBox(height: 20),
            _buildAilmentsSection(context),
            const SizedBox(height: 20),
            _buildRecitersSection(context),
            const SizedBox(height: 20),
            _buildDisclaimerSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.appbarText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.6,
            color: AppColors.blackTextThemed(context),
          ),
        ),
      ],
    );
  }

  Widget _buildComprehensiveGuidelines(BuildContext context, ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTawhidSection(context),
        const SizedBox(height: 20),
        _buildSpiritualPreparationSection(context),
        const SizedBox(height: 20),
        _buildUnderstandingRuqyahSection(context),
        const SizedBox(height: 20),
        _buildConductDuringRuqyahSection(context),
        const SizedBox(height: 20),
        _buildPostRuqyahSection(context),
        const SizedBox(height: 20),
        _buildWhenNotToListenSection(context),
      ],
    );
  }

  Widget _buildTawhidSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appbarText.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.appbarText.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: AppColors.appbarText, size: 20),
              const SizedBox(width: 8),
              Text(
                easy.tr('ruqiyah_guidelines_section1_title'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.appbarText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section1_sub1_title'),
            easy.tr('ruqiyah_guidelines_section1_sub1_content'),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section1_sub2_title'),
            easy.tr('ruqiyah_guidelines_section1_sub2_content'),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section1_sub3_title'),
            easy.tr('ruqiyah_guidelines_section1_sub3_content'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpiritualPreparationSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerColorThemed(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorderThemed(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            easy.tr('ruqiyah_guidelines_section2_title'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.appbarText,
            ),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section2_sub1_title'),
            easy.tr('ruqiyah_guidelines_section2_sub1_content'),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section2_sub2_title'),
            easy.tr('ruqiyah_guidelines_section2_sub2_content'),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section2_sub3_title'),
            easy.tr('ruqiyah_guidelines_section2_sub3_content'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnderstandingRuqyahSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appbarText.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.appbarText.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            easy.tr('ruqiyah_guidelines_section3_title'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.appbarText,
            ),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section3_sub1_title'),
            easy.tr('ruqiyah_guidelines_section3_sub1_content'),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section3_sub2_title'),
            easy.tr('ruqiyah_guidelines_section3_sub2_content'),
          ),
        ],
      ),
    );
  }

  Widget _buildConductDuringRuqyahSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerColorThemed(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorderThemed(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            easy.tr('ruqiyah_guidelines_section4_title'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.appbarText,
            ),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section4_sub1_title'),
            easy.tr('ruqiyah_guidelines_section4_sub1_content'),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section4_sub2_title'),
            easy.tr('ruqiyah_guidelines_section4_sub2_content'),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section4_sub3_title'),
            easy.tr('ruqiyah_guidelines_section4_sub3_content'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostRuqyahSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appbarText.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.appbarText.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            easy.tr('ruqiyah_guidelines_section5_title'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.appbarText,
            ),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section5_sub1_title'),
            easy.tr('ruqiyah_guidelines_section5_sub1_content'),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section5_sub2_title'),
            easy.tr('ruqiyah_guidelines_section5_sub2_content'),
          ),
          const SizedBox(height: 12),
          _buildSubSection(
            context,
            easy.tr('ruqiyah_guidelines_section5_sub3_title'),
            easy.tr('ruqiyah_guidelines_section5_sub3_content'),
          ),
        ],
      ),
    );
  }

  Widget _buildWhenNotToListenSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.wrongOption.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.wrongOption.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.wrongOption, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  easy.tr('ruqiyah_guidelines_section6_title'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.wrongOption,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            easy.tr('ruqiyah_guidelines_section6_intro'),
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.6,
              color: AppColors.blackTextThemed(context),
            ),
          ),
          const SizedBox(height: 16),
          _buildWarningPoint(
            context,
            easy.tr('ruqiyah_guidelines_section6_warning1_title'),
            easy.tr('ruqiyah_guidelines_section6_warning1_content'),
          ),
          const SizedBox(height: 12),
          _buildWarningPoint(
            context,
            easy.tr('ruqiyah_guidelines_section6_warning2_title'),
            easy.tr('ruqiyah_guidelines_section6_warning2_content'),
          ),
          const SizedBox(height: 12),
          _buildWarningPoint(
            context,
            easy.tr('ruqiyah_guidelines_section6_warning3_title'),
            easy.tr('ruqiyah_guidelines_section6_warning3_content'),
          ),
          const SizedBox(height: 12),
          _buildWarningPoint(
            context,
            easy.tr('ruqiyah_guidelines_section6_warning4_title'),
            easy.tr('ruqiyah_guidelines_section6_warning4_content'),
          ),
          const SizedBox(height: 12),
          _buildWarningPoint(
            context,
            easy.tr('ruqiyah_guidelines_section6_warning5_title'),
            easy.tr('ruqiyah_guidelines_section6_warning5_content'),
          ),
          const SizedBox(height: 12),
          _buildWarningPoint(
            context,
            easy.tr('ruqiyah_guidelines_section6_warning6_title'),
            easy.tr('ruqiyah_guidelines_section6_warning6_content'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.appbarText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.6,
            color: AppColors.blackTextThemed(context),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningPoint(BuildContext context, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.containerColorThemed(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wrongOption.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.wrongOption,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.5,
              color: AppColors.blackTextThemed(context),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildGuideline(BuildContext context, String text) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           margin: const EdgeInsets.only(top: 6),
  //           width: 6,
  //           height: 6,
  //           decoration: BoxDecoration(
  //             color: AppColors.appbarText,
  //             shape: BoxShape.circle,
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Text(
  //             text,
  //             style: GoogleFonts.poppins(
  //               fontSize: 13,
  //               height: 1.6,
  //               color: AppColors.blackTextThemed(context),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAilmentsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerColorThemed(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyBorderThemed(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            easy.tr('ruqiyah_ailments_title'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.appbarText,
            ),
          ),
          const SizedBox(height: 12),
          _buildAilmentItem(context, 'السحر', easy.tr('magic')),
          _buildAilmentItem(context, 'العين', easy.tr('evil_eye')),
          _buildAilmentItem(context, 'المس', easy.tr('possession')),
          _buildAilmentItem(context, 'الحسد', easy.tr('jealousy')),
          _buildAilmentItem(context, 'سحر المحبة', easy.tr('love_magic')),
          _buildAilmentItem(context, 'الأمراض النفسية والجسدية', easy.tr('overall_healing')),
        ],
      ),
    );
  }

  Widget _buildAilmentItem(BuildContext context, String arabic, String english) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.correctOption,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arabic,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackTextThemed(context),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  english,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.greyTextThemed(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecitersSection(BuildContext context, ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appbarText.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.appbarText.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: AppColors.appbarText, size: 20),
              const SizedBox(width: 8),
              Text(
                easy.tr('ruqiyah_reciters_title'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.appbarText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            easy.tr('ruqiyah_reciters_content'),
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.6,
              color: AppColors.blackTextThemed(context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.containerColorThemed(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greyBorderThemed(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReciterName(context,'Sheikh Abdirahman Abdullahi Hashi'),
                const SizedBox(height: 8),
                _buildReciterName(context,'Sheikh Muse Dhaqane Ahmed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReciterName(BuildContext context, String name) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: AppColors.correctOption, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.blackTextThemed(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.wrongOption.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.wrongOption.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.wrongOption, size: 24),
              const SizedBox(width: 8),
              Text(
                easy.tr('ruqiyah_disclaimer_title'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.wrongOption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            easy.tr('ruqiyah_disclaimer_content'),
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.6,
              color: AppColors.blackTextThemed(context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.containerColorThemed(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDisclaimerPoint(context, easy.tr('ruqiyah_disclaimer_point_1')),
                _buildDisclaimerPoint(context,easy.tr('ruqiyah_disclaimer_point_2')),
                _buildDisclaimerPoint(context, easy.tr('ruqiyah_disclaimer_point_3')),
                _buildDisclaimerPoint(context, easy.tr('ruqiyah_disclaimer_point_4')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, color: AppColors.wrongOption, size: 20),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.5,
                color: AppColors.blackText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
