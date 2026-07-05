import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';

class FiqhScreen extends StatelessWidget {
  const FiqhScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                colorFilter: ColorFilter.mode(AppColors.whiteText, BlendMode.srcIn),
              ),
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: easy.tr('fiqh'),
                    child: Text(
                      easy.tr('framework_title'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppColors.whiteText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow
                          .ellipsis,
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    easy.tr('framework_text'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.whiteText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow
                        .ellipsis,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                easy.tr('intro_title'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                easy.tr('intro_text'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                easy.tr('foundations_title'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${easy.tr('fiqh_definition')}\n${easy.tr('fiqh_domains_intro')}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '• ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.greyTextThemed(context),
                      ),
                    ),
                    TextSpan(
                      text: '${easy.tr('ibadat_title')} -',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.greyTextThemed(context),
                      ),
                    ),
                    TextSpan(
                      text: easy.tr('fiqh_ibadat'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.greyTextThemed(context),
                      ),
                    ),
                    TextSpan(
                      text: '• ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.greyTextThemed(context),
                      ),
                    ),
                    TextSpan(
                      text: '${easy.tr('muamalat_title')} -',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.greyTextThemed(context),
                      ),
                    ),
                    TextSpan(
                      text: easy.tr('fiqh_muamalat'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.greyTextThemed(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                easy.tr('title_sources'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                easy.tr('source_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                easy.tr('quran_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                easy.tr('quran_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                easy.tr('sunnah_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                easy.tr('sunnah_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                easy.tr('ijma_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                easy.tr('ijma_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                easy.tr('qiyas_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                easy.tr('qiyas_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                easy.tr('modern_fiqh_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                easy.tr('modern_fiqh_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                easy.tr('authority_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                easy.tr('authority_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                easy.tr('sahabah_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                easy.tr('sahabah_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                easy.tr('madhhabs_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                easy.tr('madhhabs_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                easy.tr('madhhabs_list'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                easy.tr('madhhabs_note'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                easy.tr('disputes_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                easy.tr('disputes_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                easy.tr('modern_scholars_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                easy.tr('modern_scholars_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                easy.tr('conclusion_heading'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.blackTextThemed(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                easy.tr('conclusion_description'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.greyTextThemed(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
