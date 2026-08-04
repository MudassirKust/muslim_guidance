import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import 'package:islamlearning/views/premium_screen.dart';

const _kDarkTeal = Color(0xFF0F322C);
const _kGoldBright = Color(0xFFFFE088);
const _kGoldMid = Color(0xFFE9C349);
const _kGoldDark = Color(0xFFB6922E);

class DiscountPaywallDialog extends StatefulWidget {
  const DiscountPaywallDialog({super.key});

  @override
  State<DiscountPaywallDialog> createState() => _DiscountPaywallDialogState();
}

class _DiscountPaywallDialogState extends State<DiscountPaywallDialog> {
  static const _initialSeconds = 10 * 60;
  int _secondsLeft = _initialSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _mm => (_secondsLeft ~/ 60).toString().padLeft(2, '0');
  String get _ss => (_secondsLeft % 60).toString().padLeft(2, '0');

  List<({String icon, String title, String desc})> get _features => [
        (
          icon: AppImages.icIslam,
          title: easy.tr('paywall_feature_ad_free_title'),
          desc: easy.tr('paywall_feature_ad_free_desc')
        ),
        (
          icon: AppImages.icQuran,
          title: easy.tr('paywall_feature_quran_title'),
          desc: easy.tr('paywall_feature_quran_desc')
        ),
        (
          icon: AppImages.icPrayerReminder,
          title: easy.tr('paywall_feature_ruqyah_title'),
          desc: easy.tr('paywall_feature_ruqyah_desc')
        ),
        (
          icon: AppImages.icQuiz,
          title: easy.tr('paywall_feature_quiz_title'),
          desc: easy.tr('paywall_feature_quiz_desc')
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: _kDarkTeal,
          child: Stack(
            children: [
              _HeroImage(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Column(children: [
                        const SizedBox(height: 20),
                        _GoldText(easy.tr('paywall_discount'),
                            fontSize: 40, fontWeight: FontWeight.w800),
                        const SizedBox(height: 10),
                        _PriceBadge(),
                        const SizedBox(height: 10),
                        Text(
                          easy.tr('paywall_title'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ..._features.map((f) => _FeatureCard(
                            icon: f.icon, title: f.title, desc: f.desc)),
                        const SizedBox(height: 20),
                      ]),
                    ),
                    if (Platform.isAndroid)
                      _PurchaseButton(onTap: () {
                        Navigator.of(context).pop();
                        Get.to(() => const PremiumScreen());
                      }),
                    const SizedBox(height: 12),
                    _UrgencyRow(mm: _mm, ss: _ss),
                    const SizedBox(height: 4),
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

class _HeroImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.bgOnboarding,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.45),
            colorBlendMode: BlendMode.darken,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _kDarkTeal],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const _GoldText(this.text,
      {required this.fontSize, required this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [_kGoldBright, _kGoldMid, _kGoldDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class _PriceBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: _kGoldMid.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(100),
        color: _kGoldBright.withValues(alpha: 0.08),
      ),
      child: Text(
        easy.tr('paywall_price'),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _kGoldBright,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const _FeatureCard(
      {required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              icon,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PurchaseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kGoldBright, _kGoldMid],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          easy.tr('purchase_now'),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _kDarkTeal,
          ),
        ),
      ),
    );
  }
}

class _UrgencyRow extends StatelessWidget {
  final String mm;
  final String ss;

  const _UrgencyRow({required this.mm, required this.ss});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          easy.tr('paywall_urgency'),
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: _kGoldBright.withValues(alpha: 0.85),
          ),
        ),
        _TimerBox(digit: mm[0]),
        _TimerBox(digit: mm[1]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(':',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700)),
        ),
        _TimerBox(digit: ss[0]),
        _TimerBox(digit: ss[1]),
      ],
    );
  }
}

class _TimerBox extends StatelessWidget {
  final String digit;

  const _TimerBox({required this.digit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
