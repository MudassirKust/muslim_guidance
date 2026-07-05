import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:islamlearning/views/dua_image_viewer_screen.dart';
import 'constants/appcolors.dart';
import 'widgets/animated_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'constants/appimages.dart';

class DuaCollectionScreen extends StatelessWidget {
  const DuaCollectionScreen({super.key});

  static const int _totalDuas = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor(context),
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
                colorFilter: const ColorFilter.mode(
                  AppColors.whiteText,
                  BlendMode.srcIn,
                ),
              ),
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dua Collection',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.whiteText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalDuas duas available',
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
      body: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _totalDuas,
          itemBuilder: (context, index) {
            final duaNumber = index + 1;
            final imagePath = 'assets/images/bn_dua_$duaNumber.png';

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: _DuaListItem(
                    duaNumber: duaNumber,
                    imagePath: imagePath,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DuaListItem extends StatelessWidget {
  final int duaNumber;
  final String imagePath;

  const _DuaListItem({
    required this.duaNumber,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TouchRippleEffect(
        rippleColor: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => DuaImageViewerScreen(
              duaNumber: duaNumber,
              imagePath: imagePath,
            )),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.containerColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Hero(
                  tag: imagePath,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.appbarText.withValues(alpha:0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$duaNumber',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appbarText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Dua $duaNumber',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackText(context),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.zoom_in_rounded,
                      size: 18,
                      color: AppColors.greyText(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}