import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'constants/appcolors.dart';

class ZakatInfoScreen extends StatelessWidget {
  const ZakatInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarText,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          easy.tr('zakat_information'),
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
              title: easy.tr('zakat_title'),
              content: easy.tr('zakat_content'),
              context: context,
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: easy.tr('zakat_wisdom_title'),
              content: easy.tr('zakat_wisdom_content'),
              context: context,
            ),
            const SizedBox(height: 16),
            _buildPointsList(context),
            const SizedBox(height: 20),
            _buildSection(
              title: easy.tr('zakat_framework_title'),
              content: easy.tr('zakat_framework_content'),
              context: context,
            ),
            const SizedBox(height: 16),
            _buildNisabSection(context),
            const SizedBox(height: 16),
            _buildRateSection(context),
            const SizedBox(height: 16),
            _buildZakatableSection(context),
            const SizedBox(height: 20),
            _buildSection(
              title: easy.tr('zakat_intention_title'),
              content: easy.tr('zakat_intention_content'),
              context: context,
            ),
            const SizedBox(height: 20),
            _buildRecipientsSection(context),
            const SizedBox(height: 20),
            _buildFitrSection(context),
            const SizedBox(height: 20),
            _buildSection(
              title: easy.tr('zakat_final_word_title'),
              content: easy.tr('zakat_final_word_content'),
              context: context,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required String content,
      required BuildContext context}) {
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

  Widget _buildPointsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPoint(
          title: easy.tr('zakat_point_1_title'),
          content: easy.tr('zakat_point_1_content'),
          context: context,
        ),
        const SizedBox(height: 12),
        _buildPoint(
          title: easy.tr('zakat_point_2_title'),
          content: easy.tr('zakat_point_2_content'),
          context: context,
        ),
        const SizedBox(height: 12),
        _buildPoint(
          title: easy.tr('zakat_point_3_title'),
          content: easy.tr('zakat_point_3_content'),
          context: context,
        ),
      ],
    );
  }

  Widget _buildPoint(
      {required String title,
      required String content,
      required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.containerColorThemed(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyBorderThemed(context)),
      ),
      child: Column(
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
              fontSize: 12,
              height: 1.5,
              color: AppColors.blackTextThemed(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appbarText.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.appbarText.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            easy.tr('zakat_nisaab_title'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.appbarText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            easy.tr('zakat_nisaab_content'),
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

  Widget _buildRateSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            easy.tr('zakat_rate_title'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            easy.tr('zakat_rate_content'),
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

  Widget _buildZakatableSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          easy.tr('zakat_zakatable_title'),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.appbarText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          easy.tr('zakat_zakatable_content'),
          style: GoogleFonts.poppins(
            fontSize: 12,
            height: 1.5,
            color: AppColors.blackTextThemed(context),
          ),
        ),
        const SizedBox(height: 8),
        _buildBulletList([
          easy.tr('zakat_zakatable_item_1'),
          easy.tr('zakat_zakatable_item_2'),
          easy.tr('zakat_zakatable_item_3'),
          easy.tr('zakat_zakatable_item_4'),
          easy.tr('zakat_zakatable_item_5'),
        ], context),
      ],
    );
  }

  Widget _buildRecipientsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          easy.tr('zakat_recipients_title'),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.appbarText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          easy.tr('zakat_recipients_content'),
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.6,
            color: AppColors.blackTextThemed(context),
          ),
        ),
        const SizedBox(height: 12),
        _buildBulletList([
          easy.tr('zakat_recipient_1'),
          easy.tr('zakat_recipient_2'),
          easy.tr('zakat_recipient_3'),
          easy.tr('zakat_recipient_4'),
          easy.tr('zakat_recipient_5'),
          easy.tr('zakat_recipient_6'),
          easy.tr('zakat_recipient_7'),
          easy.tr('zakat_recipient_8'),
        ], context),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  easy.tr('zakat_relatives_note'),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    height: 1.5,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFitrSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          easy.tr('zakat_fitr_title'),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.appbarText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          easy.tr('zakat_fitr_content'),
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
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            easy.tr('zakat_hanafi_opinion'),
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: Colors.orange.shade900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletList(List<String> items, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appbarText,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.blackTextThemed(context),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
