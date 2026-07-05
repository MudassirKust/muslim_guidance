import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/appcolors.dart';

class DhikrCardItem extends StatelessWidget {
  final String arabic;
  final String transliteration;
  final String meaning;

  const DhikrCardItem({
    super.key,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            arabic,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              //height: 1.8,
              color: AppColors.appbarText,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            transliteration,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              //fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: AppColors.blackTextThemed(context),
            ),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          meaning,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.greyTextThemed(context),
          ),
        ),
      ],
    );
  }
}