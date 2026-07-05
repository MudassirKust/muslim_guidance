import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/names_controller.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class AsmaUlHasna extends StatelessWidget {
  final NamesController controller = Get.put(NamesController());

  AsmaUlHasna({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.appbarText),
        );
      }

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
                child: Hero(
                  tag: easy.tr('99_names_title'),
                  child: Text(
                    easy.tr('99_names_title'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.whiteText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.names.length,
          itemBuilder: (context, index) {
            final name = controller.names[index];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 50),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.appbarText,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${name.number}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.buttonText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                name.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.appbarText,
                                ),
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          name.transliteration,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.blackTextThemed(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        controller.localized(name.meaning),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyTextThemed(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const Column(
            children: [
              SizedBox(height: 15),
              Divider(height: 1),
              SizedBox(height: 15),
            ],
          ),
        ),
      );
    });
  }
}
