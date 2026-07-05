import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class GridItem extends StatelessWidget {
  final String svgPath;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPng;

  const GridItem({
    super.key,
    required this.svgPath,
    required this.label,
    required this.onTap,
    required this.subtitle,
    required this.isPng,
  });

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;

    // Special handling for Q/A to preserve exact format
    if (text == 'Q/A') return 'Q/A';

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: Offset(0, 14),
              blurRadius: 24,
              spreadRadius: 0)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Hero(
                  tag: label,
                  child: TouchRippleEffect(
                    rippleColor: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                    onTap: onTap,
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15)),
                        color: AppColors.containerColor(context),
                        // boxShadow: [
                        //   BoxShadow(
                        //       color: Colors.black.withValues(alpha: 0.1),
                        //       offset: Offset(0, -4),
                        //       blurRadius: 24,
                        //       spreadRadius: 0)
                        // ],
                      ),
                      child: isPng
                          ? Image.asset(
                              svgPath,
                              width: 45,
                              height: 45,
                            )
                          : SvgPicture.asset(
                              svgPath,
                              width: 45,
                              height: 45,
                              colorFilter: ColorFilter.mode(
                                  AppColors.appbarText, BlendMode.srcIn),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    _capitalizeWords(easy.tr(label)),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackText(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                // const SizedBox(height: 6),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 5.0),
                //   child: Text(
                //     subtitle,
                //     textAlign: TextAlign.center,
                //     style: GoogleFonts.poppins(
                //       fontSize: 10,
                //       fontWeight: FontWeight.w400,
                //       color: Color(0xff596877),
                //     ),
                //     overflow: TextOverflow.ellipsis,
                //     maxLines: 3,
                //   ),
                // ),
                // SizedBox(height: 6),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 6),
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Color(0xffDFE9E7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 12,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
          ),
          // SizedBox(height: 5),
        ],
      ),
    );
  }
}
