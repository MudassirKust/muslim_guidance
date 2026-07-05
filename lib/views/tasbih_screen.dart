import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import '../controllers/tasbih_controller.dart';
import 'constants/appcolors.dart';
import 'widgets/animated_button.dart';

class TasbihScreen extends StatelessWidget {
  TasbihScreen({super.key});

  final TasbihController controller =
      Get.put(TasbihController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => controller.loadTasbihData());

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
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors.whiteText,
                size: 24,
              ),
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  easy.tr('tasbih'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.whiteText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  easy.tr('digital_prayer_counter'),
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
        final lang = controller.getLanguageKey();

        if (controller.dhikrList.isEmpty) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.appbarText));
        }

        final selectedDhikr = controller.selectedDhikr;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Enhanced Dhikr Selection Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.containerColorThemed(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greyBorderThemed(context)
                          .withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Enhanced Dhikr Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ButtonAnimationWidget(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.appbarText.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    AppColors.appbarText.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.appbarText,
                              size: 16,
                            ),
                          ),
                          onTap: () => controller.previousDhikr(),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.appbarText.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${controller.selectedDhikrIndex.value + 1} / ${controller.dhikrList.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.appbarText,
                            ),
                          ),
                        ),
                        ButtonAnimationWidget(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.appbarText.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    AppColors.appbarText.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.appbarText,
                              size: 16,
                            ),
                          ),
                          onTap: () => controller.nextDhikr(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Enhanced Arabic Text with better styling
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.appbarText.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.appbarText.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        selectedDhikr.arabic,
                        style: GoogleFonts.amiri(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appbarText,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Enhanced Transliteration
                    Text(
                      selectedDhikr.transliteration[lang] ??
                          selectedDhikr.transliteration['en'] ??
                          '',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.appbarText,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Enhanced Translation
                    Text(
                      selectedDhikr.translation[lang] ??
                          selectedDhikr.translation['en'] ??
                          '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyTextThemed(context),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),

                    // Enhanced Virtue with better styling
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.appbarText.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.appbarText.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.appbarText,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedDhikr.virtue[lang] ??
                                  selectedDhikr.virtue['en'] ??
                                  '',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: AppColors.greyTextThemed(context),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Enhanced Counter Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.containerColorThemed(context),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greyBorderThemed(context)
                          .withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Enhanced Target Count Selector
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.appbarText.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.appbarText.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flag,
                            color: AppColors.appbarText,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${easy.tr('target')}: ',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.appbarText,
                            ),
                          ),
                          DropdownButton<int>(
                            value: controller.targetCount.value,
                            underline: Container(),
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: AppColors.appbarText),
                            items: [33, 99, 100, 500, 1000, 1500].map((count) {
                              return DropdownMenuItem<int>(
                                value: count,
                                child: Text(
                                  count.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.appbarText,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.setTargetCount(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Enhanced Count Display with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      transform: controller.isVibrating.value
                          ? (Matrix4.identity()..scale(1.15))
                          : Matrix4.identity(),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: controller.count.value >=
                                  controller.targetCount.value
                              ? AppColors.appbarText.withValues(alpha: 0.1)
                              : AppColors.appbarText.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: controller.count.value >=
                                    controller.targetCount.value
                                ? AppColors.appbarText
                                : AppColors.appbarText.withValues(alpha: 0.2),
                            width: controller.count.value >=
                                    controller.targetCount.value
                                ? 2
                                : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.appbarText.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          controller.count.value.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 70,
                            fontWeight: FontWeight.w800,
                            color: controller.count.value >=
                                    controller.targetCount.value
                                ? AppColors.appbarText
                                : AppColors.greyText(context),
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Enhanced Progress Bar
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greyTextThemed(context),
                              ),
                            ),
                            Text(
                              '${controller.targetCount.value}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greyTextThemed(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.greyText(context)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: controller.targetCount.value > 0
                                ? (controller.count.value /
                                        controller.targetCount.value)
                                    .clamp(0.0, 1.0)
                                : 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: controller.count.value >=
                                        controller.targetCount.value
                                    ? AppColors.appbarText
                                    : AppColors.appbarText
                                        .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Enhanced Counter Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Enhanced Decrement Button
                        ButtonAnimationWidget(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.greyText(context)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.greyText(context)
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.remove,
                              color: AppColors.appbarText,
                              size: 24,
                            ),
                          ),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            controller.decrementCount();
                          },
                        ),

                        // Enhanced Main Count Button
                        ButtonAnimationWidget(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.appbarText,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.appbarText
                                      .withValues(alpha: 0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppColors.buttonText,
                              size: 40,
                            ),
                          ),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            controller.incrementCount();
                          },
                        ),

                        // Enhanced Reset Button
                        ButtonAnimationWidget(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.refresh,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            controller.resetCount();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Enhanced Dhikr List
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.containerColorThemed(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greyBorderThemed(context)
                          .withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: AppColors.appbarText,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          easy.tr('select_dhikr'),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.appbarText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...controller.dhikrList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dhikr = entry.value;
                      final isSelected =
                          controller.selectedDhikrIndex.value == index;

                      return ButtonAnimationWidget(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.appbarText.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.appbarText
                                  : AppColors.greyText(context)
                                      .withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.appbarText
                                      : AppColors.greyText(context)
                                          .withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dhikr.transliteration[lang] ??
                                          dhikr.transliteration['en'] ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.appbarText,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      dhikr.translation[lang] ??
                                          dhikr.translation['en'] ??
                                          '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            AppColors.greyTextThemed(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.appbarText,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                        onTap: () => controller.selectDhikr(index),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
