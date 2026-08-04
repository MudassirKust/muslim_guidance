import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import '../controllers/faq_controller.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class FaqScreen extends StatelessWidget {
  FaqScreen({
    super.key,
  }) {
    Get.put(FaqController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaqController>();

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
                colorFilter:
                    ColorFilter.mode(AppColors.whiteText, BlendMode.srcIn),
              ),
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: easy.tr('qa'),
                  child: Text(
                    easy.tr('qa_title'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.whiteText,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  easy.tr('qa_description'),
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.appbarText,
            ),
          );
        }

        if (controller.faqData.isEmpty) {
          return Center(
            child: Text(
              easy.tr('no_faq_data'),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          );
        }

        final selectedCategory =
            controller.faqData[controller.selectedCategoryIndex.value];
        final isExpandedList = controller.expansionStates;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                easy.tr('topics_label'),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.blackTextThemed(context)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.faqData.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isSelected =
                        controller.selectedCategoryIndex.value == index;
                    final category = controller.faqData[index];

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: SizedBox(
                            width: 80,
                            child: Column(
                              children: [
                                TouchRippleEffect(
                                  rippleColor: Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => controller.changeCategory(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.buttonColor
                                          : AppColors.containerColorThemed(
                                              context),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SvgPicture.asset(
                                      category.iconPath,
                                      height: 28,
                                      width: 28,
                                      colorFilter: ColorFilter.mode(
                                        isSelected
                                            ? AppColors.buttonText
                                            : AppColors.buttonColor,
                                        BlendMode.srcIn,
                                      ),
                                      // color: isSelected
                                      //     ? AppColors.buttonText
                                      //     : AppColors.buttonColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  easy.tr(category.translationKey),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.buttonColor
                                        : AppColors.blackTextThemed(context),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    itemCount: selectedCategory.items.length,
                    itemBuilder: (context, index) {
                      final faq = selectedCategory.items[index];
                      // final isExpanded = isExpandedList[index].value;

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Obx(() {
                              final isExpanded = isExpandedList[index].value;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    collapsedBackgroundColor:
                                        AppColors.containerColorThemed(context),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    collapsedShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor:
                                        AppColors.containerColorThemed(context),
                                    onExpansionChanged: (value) => controller
                                        .toggleExpansion(index, value),
                                    title: Text(
                                      '${index + 1}. ${controller.localized(faq.questionTranslations)}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        isExpanded ? Icons.remove : Icons.add,
                                        key: ValueKey(isExpanded),
                                        color:
                                            AppColors.blackTextThemed(context),
                                      ),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          controller.localized(
                                              faq.answerTranslations),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.greyTextThemed(
                                                context),
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      if (faq.source != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                            bottom: 10,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              faq.source!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.greyTextThemed(
                                                    context),
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
