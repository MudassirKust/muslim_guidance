import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dhikr_controller.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';
import 'widgets/dhikr_table_row.dart';

class DhikrDetailScreen extends StatelessWidget {
  final int categoryIndex;
  final String categoryTitle;
  final DhikrController controller = Get.put(DhikrController());

  DhikrDetailScreen({
    super.key,
    required this.categoryIndex,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
            child: CircularProgressIndicator(
          color: AppColors.appbarText,
        )
        );
      }

      final category = controller.getCategory(categoryIndex);
      if (category == null) {
        return const Center(child: Text('Category not found'));
      }

      return Scaffold(
          backgroundColor: AppColors.bgColorThemed(context),
          appBar: AppBar(
            backgroundColor: AppColors.appbarText,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
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
                        tag: categoryTitle,
                        child: Text(
                          categoryTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: AppColors.whiteText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: category.dhikrs.length,
            itemBuilder: (context, index) {
              final dhikr = category.dhikrs[index];

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: DhikrCardItem(
                      arabic: dhikr.arabic,
                      transliteration: dhikr.transliteration,
                      meaning: controller.localized(dhikr.meaning),
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
          ));
    });
  }
}