import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/views/constants/appcolors.dart';

class DuaTableRowItem extends StatelessWidget {
  final String situation;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String source;
  final bool isHeader;

  const DuaTableRowItem({
    super.key,
    required this.situation,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.source,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          situation,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.blackTextThemed(context),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            arabic,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xff2F9E92),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          transliteration,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.blackTextThemed(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          meaning,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xff587677),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            source,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xff676F7E),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
