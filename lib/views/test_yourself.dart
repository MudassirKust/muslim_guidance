import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import '../controllers/ad_controller.dart';
import '../controllers/test_yourself_controller.dart';
import '../controllers/subscription_controller.dart';
import '../models/quiz_category.dart';
import 'constants/appcolors.dart';
import 'premium_screen.dart';
import 'widgets/animated_button.dart';

class TestYourself extends StatelessWidget {
  const TestYourself({super.key});

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.put(QuizController());

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
                  onTap: () {
                    final isPremium =
                        Get.find<SubscriptionController>().isPremium;
                    if (isPremium &&
                        !controller.showCategorySelector.value &&
                        controller.questions.isNotEmpty) {
                      controller.backToCategories();
                    } else {
                      Get.back();
                    }
                  }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: easy.tr('test_yourself'),
                    child: Text(
                      easy.tr('test_yourself'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppColors.whiteText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    easy.tr('test_your_knowledge'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.whiteText,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: AnimationLimiter(
                child: Obx(() {
                  if (controller.showCategorySelector.value) {
                    return _buildCategorySelector(context, controller);
                  }

                  if (controller.isLoading.value ||
                      controller.questions.isEmpty) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: AppColors.appbarText,
                    ));
                  }

                  if (controller.error.value.isNotEmpty) {
                    return AnimationConfiguration.synchronized(
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 40.0,
                        child: FadeInAnimation(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: AppColors.wrongOption,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    controller.error.value,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.greyTextThemed(context),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  _QuizPrimaryButton(
                                    label: easy.tr('try_again'),
                                    onTap: controller.retry,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (controller.isQuizCompleted.value) {
                    return _buildResultsView(controller, context);
                  }

                  return AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 40.0,
                      child: FadeInAnimation(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 32),
                            child: _buildQuestionView(context, controller),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Obx(() {
              // Only show note when quiz is active (not loading, no error, not completed)
              if (controller.showCategorySelector.value ||
                  controller.isLoading.value ||
                  controller.questions.isEmpty ||
                  controller.error.value.isNotEmpty ||
                  controller.isQuizCompleted.value) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.greyBar(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'There are ${controller.totalLevels} levels. Answer ${controller.questionsPerLevel} questions — pass 80% to proceed to the next level.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.greyTextThemed(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ],
        ));
  }

  Widget _buildCategorySelector(
      BuildContext context, QuizController controller) {
    final categories = [
      (
        category: QuizCategory.normal,
        icon: Icons.quiz_outlined,
        title: 'General Islamic Knowledge',
        subtitle: 'Classic quiz with mixed topics',
      ),
      (
        category: QuizCategory.seerah,
        icon: Icons.auto_stories_outlined,
        title: 'Seerah',
        subtitle: "Prophet's biography & companions",
      ),
      (
        category: QuizCategory.islamicHistory,
        icon: Icons.history_edu_outlined,
        title: 'Islamic History',
        subtitle: 'Key events, treaties & milestones',
      ),
      (
        category: QuizCategory.nobleQuran,
        icon: Icons.menu_book_outlined,
        title: 'The Noble Quran',
        subtitle: 'Surahs, Ayat & revelation',
      ),
    ];

    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 40.0,
        child: FadeInAnimation(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 400),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    Text(
                      'Choose a Quiz Category',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppColors.blackTextThemed(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Each category tracks your progress separately.',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: AppColors.greyTextThemed(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final item in categories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ButtonAnimationWidget(
                          onTap: () => controller.startCategory(item.category),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.greyBar(context)
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.greyOption,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.appbarText
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: AppColors.appbarText,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.blackTextThemed(
                                              context),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color:
                                              AppColors.greyTextThemed(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.greyTextThemed(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView(QuizController controller, BuildContext context) {
    return Obx(() {
      // Show premium upsell when free user completes free levels
      if (controller.premiumRequired.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).width / 2),
                Icon(Icons.lock_outline, size: 80, color: AppColors.appbarText),
                const SizedBox(height: 16),
                Text(
                  "${easy.tr('level')} ${controller.completedLevel.value} Completed!",
                  style: GoogleFonts.poppins(
                      color: AppColors.appbarText,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "${easy.tr('you_scored')} ${controller.completedScore.value} / ${controller.questions.length}",
                  style: GoogleFonts.poppins(
                      color: AppColors.greyTextThemed(context),
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  "Upgrade to Premium to unlock exclusive quiz topics — Seerah, Islamic History & The Noble Quran!",
                  style: GoogleFonts.poppins(
                      color: AppColors.greyTextThemed(context),
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (Platform.isAndroid)
                  _QuizPrimaryButton(
                    label: 'Upgrade to Premium',
                    onTap: () async {
                      await Get.to(() => const PremiumScreen());
                      // After returning from premium screen, check if now premium
                      final sub = Get.find<SubscriptionController>();
                      if (sub.isPremium) {
                        await controller.continueToNextLevel();
                      }
                    },
                  ),
                const SizedBox(height: 12),
                _QuizOutlineButton(
                  label: easy.tr('try_again'),
                  onTap: controller.restartQuiz,
                ),
              ],
            ),
          ),
        );
      }

      // Show all levels completed message
      if (controller.allLevelsCompleted.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).width / 2),
                SvgPicture.asset(AppImages.trophy),
                const SizedBox(height: 16),
                Text(
                  easy.tr('all_levels_completed'),
                  style: GoogleFonts.poppins(
                      color: AppColors.appbarText,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "${easy.tr('level')} ${controller.completedLevel.value} ${easy.tr('score')}: ${controller.completedScore.value} / ${controller.questions.length}",
                  style: GoogleFonts.poppins(
                      color: AppColors.greyTextThemed(context),
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                ),
                const SizedBox(height: 24),
                _QuizPrimaryButton(
                  label: easy.tr('try_again'),
                  onTap: controller.restartQuiz,
                ),
                if (Get.find<SubscriptionController>().isPremium) ...[
                  const SizedBox(height: 12),
                  _QuizOutlineButton(
                    label: 'Change Category',
                    onTap: controller.backToCategories,
                  ),
                ],
              ],
            ),
          ),
        );
      }

      // Show level passed message
      if (controller.levelPassed.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).width / 2),
                SvgPicture.asset(AppImages.trophy),
                const SizedBox(height: 16),
                Text(
                  "${easy.tr('level')} ${controller.completedLevel.value} Completed!",
                  style: GoogleFonts.poppins(
                      color: AppColors.appbarText,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "${easy.tr('you_scored')} ${controller.completedScore.value} / ${controller.questions.length}",
                  style: GoogleFonts.poppins(
                      color: AppColors.greyTextThemed(context),
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (controller.completedLevel.value < controller.totalLevels)
                  Text(
                    "Proceeding to ${easy.tr('level')} ${controller.completedLevel.value + 1}...",
                    style: GoogleFonts.poppins(
                        color: AppColors.greyTextThemed(context),
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                  ),
                const SizedBox(height: 24),
                _QuizPrimaryButton(
                  label:
                      controller.completedLevel.value < controller.totalLevels
                          ? easy.tr('continue')
                          : easy.tr('try_again'),
                  onTap: () async {
                    await controller.continueToNextLevel();
                  },
                ),
                if (Get.find<SubscriptionController>().isPremium) ...[
                  const SizedBox(height: 12),
                  _QuizOutlineButton(
                    label: 'Change Category',
                    onTap: controller.backToCategories,
                  ),
                ],
              ],
            ),
          ),
        );
      }

      // Show level failed message
      if (controller.levelFailed.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).width / 2),
                Icon(
                  Icons.cancel_outlined,
                  size: 80,
                  color: AppColors.wrongOption,
                ),
                const SizedBox(height: 16),
                Text(
                  "${easy.tr('level')} ${controller.completedLevel.value} Failed",
                  style: GoogleFonts.poppins(
                      color: AppColors.appbarText,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "${easy.tr('you_scored')} ${controller.completedScore.value} / ${controller.questions.length}",
                  style: GoogleFonts.poppins(
                      color: AppColors.greyTextThemed(context),
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  "Resetting to ${easy.tr('level')} 1...",
                  style: GoogleFonts.poppins(
                      color: AppColors.greyTextThemed(context),
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _QuizPrimaryButton(
                  label: easy.tr('start_from_level_one'),
                  onTap: () async {
                    await controller.restartQuiz();
                  },
                ),
              ],
            ),
          ),
        );
      }

      // Default completion view (fallback)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).width / 2),
              SvgPicture.asset(AppImages.trophy),
              const SizedBox(height: 16),
              Text(
                easy.tr('quiz_completed'),
                style: GoogleFonts.poppins(
                    color: AppColors.appbarText,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                easy.tr('you_scored'),
                style: GoogleFonts.poppins(
                    color: AppColors.greyTextThemed(context),
                    fontWeight: FontWeight.w400,
                    fontSize: 14),
              ),
              Text(
                " ${controller.completedScore.value} / ${controller.questions.length}",
                style: GoogleFonts.poppins(
                    color: AppColors.blackTextThemed(context),
                    fontWeight: FontWeight.w500,
                    fontSize: 28),
              ),
              const SizedBox(height: 24),
              _QuizPrimaryButton(
                label: easy.tr('try_again'),
                onTap: controller.restartQuiz,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuestionView(BuildContext context, QuizController controller) {
    final question =
        controller.questions[controller.currentQuestionIndex.value];
    final options =
        question.options[controller.currentLang] ?? question.options['en']!;
    final questionText = controller.localized(question.question);
    final current = controller.currentQuestionIndex.value;
    final total = controller.questions.length;

    return AnimationLimiter(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 500),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 40.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              Center(
                child: Text(
                  "${easy.tr('level')} ${controller.currentLevel.value} - ${easy.tr('question')} ${current + 1} ${easy.tr('of')} $total",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    color: AppColors.greyTextThemed(context),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (current + 1) / total,
                color: AppColors.appbarText,
                backgroundColor: AppColors.greyBar(context),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),
              Text(
                questionText,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              for (int i = 0; i < options.length; i++)
                OptionButton(
                  text: options[i],
                  index: i,
                  onTap: () => controller.selectOption(i),
                  isSelected: controller.selectedOptionIndex.value == i,
                  isCorrect: controller.correctAnswerIndex == i,
                  showCorrect: controller.showCorrectAnswer.value,
                  hintRevealed: controller.hintRevealed.value,
                ),
              if (!Get.find<AdController>().isPremium.value &&
                  controller.selectedOptionIndex.value == -1 &&
                  !controller.hintRevealed.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _QuizOutlineButton(
                    label: controller.isRequestingHint.value
                        ? 'Loading Ad...'
                        : 'Watch Ad for Hint',
                    onTap: controller.requestHintViaAd,
                  ),
                ),
              const SizedBox(height: 16),
              if (controller.selectedOptionIndex.value != -1 ||
                  controller.hintRevealed.value)
                _QuizPrimaryButton(
                  label: current < total - 1
                      ? easy.tr('next_question')
                      : easy.tr('finish_quiz'),
                  onTap: controller.nextQuestion,
                ),
            ],
          )),
    );
  }
}

class _QuizPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuizPrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: onTap,
      child: Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.whiteText,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuizOutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: onTap,
      child: Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.appbarText),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.appbarText,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String text;
  final int index;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool showCorrect;
  final bool hintRevealed;

  const OptionButton({
    super.key,
    required this.text,
    required this.index,
    required this.onTap,
    required this.isSelected,
    required this.isCorrect,
    required this.showCorrect,
    this.hintRevealed = false,
  });

  Color? getBackgroundColor() {
    if (hintRevealed && isCorrect) return AppColors.correctOption;
    if (!showCorrect) return null;
    if (isCorrect) return AppColors.correctOption;
    if (isSelected) return AppColors.wrongOption;
    return null;
  }

  Color getTextColor(BuildContext context) {
    if (hintRevealed && isCorrect) return AppColors.whiteText;
    if (!showCorrect) return AppColors.greyText(context);
    if (isCorrect || isSelected) return AppColors.whiteText;
    return AppColors.greyText(context);
  }

  @override
  Widget build(BuildContext context) {
    // Hint-revealed keeps options tappable; only a fully selected answer locks them
    return GestureDetector(
      onTap: showCorrect ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          border: Border.all(color: AppColors.greyOption, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: getTextColor(context))),
      ),
    );
  }
}
