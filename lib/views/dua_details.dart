import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dua_controller.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';
import 'widgets/dua_table_row.dart';

class DuaDetailScreen extends StatelessWidget {
  final String categoryKey;
  final String categoryTitle;

  DuaDetailScreen({
    super.key,
    required this.categoryKey,
    required this.categoryTitle,
  });

  final DuaController controller = Get.put(DuaController());

  @override
  Widget build(BuildContext context) {
    controller.loadDuas(categoryKey);

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(
            color: AppColors.appbarText,
          ));
        }

        return AnimationLimiter(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.categoryDuas.length,
            itemBuilder: (context, index) {
              final dua = controller.categoryDuas[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: DuaTableRowItem(
                      situation: controller.localized(dua.situation),
                      arabic: dua.arabic,
                      transliteration: dua.transliteration,
                      meaning: controller.localized(dua.meaning),
                      source: dua.source,
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
      }),
    );
  }
}
