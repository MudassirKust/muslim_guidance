import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/controllers/auth_controller.dart';
import 'package:islamlearning/controllers/subscription_controller.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:islamlearning/views/purchase_success_screen.dart';
import 'package:islamlearning/views/nav_screen.dart';
import 'package:islamlearning/views/signin_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isYearlySelected = true;
  Offerings? _offerings;
  bool _offeringsLoading = true;

  final SubscriptionController _subController =
      Get.find<SubscriptionController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await _subController.getOfferings();
      debugPrint('[PremiumScreen] offerings: ${offerings?.all.keys.toList()}');
      debugPrint(
          '[PremiumScreen] current offering: ${offerings?.current?.identifier}');
      debugPrint(
          '[PremiumScreen] packages: ${offerings?.current?.availablePackages.map((p) => '${p.identifier}=${p.storeProduct.priceString}').toList()}');
      if (mounted) setState(() => _offerings = offerings);
    } catch (e) {
      debugPrint('[PremiumScreen] _loadOfferings error: $e');
    } finally {
      if (mounted) setState(() => _offeringsLoading = false);
    }
  }

  /// Returns the package matching [identifier] from the current offering, or null.
  Package? _packageFor(String identifier) {
    final packages = _offerings?.current?.availablePackages;
    if (packages == null) return null;
    try {
      return packages.firstWhere((p) => p.identifier == identifier);
    } catch (_) {
      return null;
    }
  }

  Future<void> _onUpgradeNow() => _directPurchase();

  Future<void> _directPurchase() async {
    if (_authController.currentUser.value == null) {
      Get.off(() => const SignInScreen());
      return;
    }

    final identifier = _isYearlySelected ? 'yearly' : 'monthly';
    final package = _packageFor(identifier);

    if (package == null) {
      Get.snackbar(
        'Not Available',
        'Products are not configured yet. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final success = await _subController.purchasePackage(package);
      if (success) {
        await _authController.saveSubscription(identifier);
        Get.to(() => const PurchaseSuccessScreen());
      }
    } on PlatformException catch (e) {
      Get.snackbar(
        'Purchase Failed',
        e.message ?? 'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _onRestorePurchase() async {
    try {
      final success = await _subController.restorePurchases();
      if (!mounted) return;
      if (success) {
        // Determine plan from restored active subscriptions and sync to Firestore.
        final activeSubs =
            _subController.customerInfo.value?.activeSubscriptions ?? [];
        final plan = activeSubs.any((id) => id.toLowerCase().contains('yearly'))
            ? 'yearly'
            : 'monthly';
        await _authController.saveSubscription(plan);

        Get.snackbar(
          'Restored',
          'Your purchase has been restored.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.off(() => NavScreen());
      } else {
        Get.snackbar(
          'Nothing to Restore',
          'No active subscription found for your account.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on PlatformException catch (e) {
      Get.snackbar(
        'Restore Failed',
        e.message ?? 'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/bg_subscription.png',
                          fit: BoxFit.fill,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroSection(),
                          const SizedBox(height: 10),
                          _buildFeaturesList(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ],
                  ),
                  _buildPurchaseSection(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black54,
                    size: 22,
                  ),
                ),
                Obx(() => TextButton(
                      onPressed: _subController.isLoading.value
                          ? null
                          : _onRestorePurchase,
                      child: Text(
                        'Restore Purchase',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black54,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Unlock Your Spiritual Journey',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'And whoever puts their trust in Allah,\nHe is sufficient for him ( Quran 65:3 )',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black54,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12),
              children: [
                const TextSpan(text: 'Grow closer to Allah with '),
                TextSpan(
                  text: 'powerful premium features',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeaturesList() {
    const features = [
      ('Ad-Free Premium', 'Uninterrupted worship. No distractions.'),
      (
        'Quran in 45+ Languages',
        "Understand Allah's message in your native tongue."
      ),
      (
        'Full Ruqyah Healing',
        'Authentic audio for protection and spiritual cure.'
      ),
      ('Islamic Knowledge Quizzes', 'Master the Quran, History, and Seerah.'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: features.map((f) => _buildFeatureItem(f.$1, f.$2)).toList(),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.buttonColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase Now',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (_offeringsLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildPricingCard(
                    title: 'Monthly Package',
                    package: _packageFor('monthly'),
                    fallbackPrice: '\$8.99',
                    period: 'Per Month',
                    isSelected: !_isYearlySelected,
                    isBestChoice: false,
                    onTap: () => setState(() => _isYearlySelected = false),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildPricingCard(
                    title: 'Yearly Package',
                    package: _packageFor('yearly'),
                    fallbackPrice: '\$79.99',
                    period: 'Per Year',
                    isSelected: _isYearlySelected,
                    isBestChoice: true,
                    onTap: () => setState(() => _isYearlySelected = true),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required Package? package,
    required String fallbackPrice,
    required String period,
    required bool isSelected,
    required bool isBestChoice,
    required VoidCallback onTap,
  }) {
    final price = package?.storeProduct.priceString ?? fallbackPrice;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.buttonColor
                    : const Color(0xFFDDDDDD),
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.buttonColor.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.buttonColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      period,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isBestChoice)
            Positioned(
              top: -11,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Best Choice',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.darkMintGreen,
                        AppColors.greenTeal,
                        AppColors.cyanGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        _subController.isLoading.value ? null : _onUpgradeNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                    ),
                    child: _subController.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Upgrade Now',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              )),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {},
            child: Text(
              'Cancel Anytime',
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: Colors.black54,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Terms & Conditions',
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black54,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '|',
                  style: GoogleFonts.poppins(
                    color: Colors.black38,
                    fontSize: 11,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Privacy Policy',
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
