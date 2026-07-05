import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/controllers/nav_controller.dart';
import 'package:islamlearning/controllers/prayer_controller.dart';
import 'package:islamlearning/views/asma_ul_hasna.dart';
import 'package:islamlearning/views/dhikr_screen.dart';
import 'package:islamlearning/views/dua_screen.dart';
import 'package:islamlearning/views/faq_screen.dart';
import 'package:islamlearning/views/fiqh_screen.dart';
import 'package:islamlearning/views/hadiths_screen.dart';
import 'package:islamlearning/views/revert_screen.dart';
import 'package:islamlearning/views/seerah_screen.dart';
import 'package:islamlearning/views/test_yourself.dart';
import 'package:islamlearning/views/umrah_screen.dart';
import 'package:islamlearning/views/hajj_screen.dart';
import 'package:islamlearning/views/ramadan_screen.dart';
import 'package:islamlearning/views/tasbih_screen.dart';
import 'package:islamlearning/views/widgets/back_press_interstital_ad_controller.dart';

import 'package:islamlearning/views/widgets/prayer_health_card.dart';
import 'package:islamlearning/views/widgets/prayer_streek_card.dart';
import 'package:islamlearning/views/widgets/show_home_native_ad_widget.dart';
import 'package:islamlearning/views/zakat_screen.dart';
import 'package:islamlearning/views/ruqiyah_screen.dart';
import 'package:islamlearning/views/dua_collection_screen.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'constants/appcolors.dart';
import 'widgets/griditem.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:islamlearning/controllers/auth_controller.dart';

import 'widgets/shimmer_cards.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RxBool _isSearchExpanded = false.obs;
  final RxString _searchQuery = ''.obs;

  late final PrayerController _prayerController;

  final BackPressInterstitialController _backPressInterstitialAd =
      Get.isRegistered<BackPressInterstitialController>()
          ? Get.find<BackPressInterstitialController>()
          : Get.put(BackPressInterstitialController(), permanent: true);

  final List<Map<String, dynamic>> allItems = [
    {
      'svg': 'assets/home/1_dhikr.png',
      'label': 'dhikr',
      "subTitle": "Remember Allah",
      'screen': const DhikrScreen(),
      'description':
          'Remembrance of Allah through various forms of dhikr and supplications.',
      'category': 'worship',
      'is_png': true,
    },
    {
      'svg': 'assets/home/2_hadith.svg',
      'label': 'hadiths',
      "subTitle": "Teachings of Prophet (PBUH)",
      'screen': const HadithsScreen(),
      'description':
          'Sayings and actions of Prophet Muhammad (PBUH) for guidance.',
      'category': 'knowledge',
      'is_png': false,
    },
    {
      'svg': 'assets/home/3_seerah.svg',
      'label': 'seerah',
      "subTitle": "Life of Prophet (PBUH)",
      'screen': SeerahScreen(),
      'description': 'Biography and life story of Prophet Muhammad (PBUH).',
      'category': 'history',
      'is_png': false,
    },
    {
      'svg': 'assets/home/4_fiqah.svg',
      'label': 'fiqh',
      'screen': const FiqhScreen(),
      "subTitle": "Islamic Jurisprudence",
      'description':
          'Islamic jurisprudence and understanding of religious laws.',
      'category': 'knowledge',
      'is_png': false,
    },
    {
      'svg': 'assets/home/5_dua.png',
      'label': 'dua',
      "subTitle": "Supplication for every need",
      'screen': const DuaScreen(),
      'description':
          'Supplications and prayers for various occasions and needs.',
      'category': 'worship',
      'is_png': true,
    },
    {
      'svg': 'assets/home/6_revert_convert.svg',
      'label': 'revert_convert',
      "subTitle": "Guidance for new Muslims",
      'screen': const RevertScreen(),
      'description': 'Resources and guidance for new Muslims and converts.',
      'category': 'guidance',
      'is_png': false,
    },
    {
      'svg': 'assets/home/7_quiz.svg',
      'label': 'test_yourself',
      "subTitle": "Learn & test your knowledge",
      'screen': const TestYourself(),
      'description':
          'Test your Islamic knowledge through quizzes and assessments.',
      'category': 'education',
      'is_png': false,
    },
    {
      'svg': 'assets/home/8_qa.svg',
      'label': 'Q/A',
      "subTitle": "Ask & Get Answer",
      'screen': FaqScreen(),
      'description':
          'Frequently asked questions about Islam and common queries.',
      'category': 'guidance',
      'is_png': false,
    },
    {
      'svg': 'assets/home/9_umra.png',
      'label': 'umrah',
      "subTitle": "Plan your journey",
      'screen': UmrahScreen(),
      'description': 'Complete guide to performing Umrah pilgrimage.',
      'category': 'worship',
      'is_png': true,
    },
    {
      'svg': 'assets/home/10_huj.png',
      'label': 'hajj',
      "subTitle": "Complete Guidance",
      'screen': HajjScreen(),
      'description': 'Complete guide to performing Hajj pilgrimage.',
      'category': 'worship',
      'is_png': true,
    },
    {
      'svg': 'assets/home/11_ramazan.svg',
      'label': 'ramadan',
      "subTitle": "Make the most of Ramadan",
      'screen': RamadanScreen(),
      'description':
          'Complete guide to Ramadan fasting and spiritual practices.',
      'category': 'worship',
      'is_png': false,
    },
    {
      'svg': 'assets/home/12_tasbih.png',
      'label': 'tasbih',
      "subTitle": "Digital Tasbih",
      'screen': TasbihScreen(),
      'description': 'Digital prayer counter for dhikr and remembrance.',
      'category': 'worship',
      'is_png': true,
    },
    {
      'svg': 'assets/home/Allah.svg',
      'label': '99_names_title',
      "subTitle": "Asma ul Hassna",
      'screen': AsmaUlHasna(),
      'description': 'The 99 beautiful names of Allah and their meanings.',
      'category': 'knowledge',
      'is_png': false,
    },
    {
      'svg': 'assets/home/14_zakat.png',
      'label': 'zakat',
      "subTitle": "Calculate and Give Zakat",
      'screen': ZakatScreen(),
      'description': 'Calculate your Zakat obligation based on your wealth.',
      'category': 'worship',
      'is_png': true,
    },
    {
      'svg': 'assets/images/ruqiyah.svg',
      'label': 'ruqiyah',
      'screen': RuqiyahScreen(),
      'description':
          'Islamic healing audio for spiritual ailments and protection.',
      'category': 'worship',
      'premium': true,
      "subTitle": "Spiritual healing & protection",
      'is_png': false,
    },
    {
      'svg': 'assets/images/dailydua.svg',
      'label': 'dua_collection',
      'screen': const DuaCollectionScreen(),
      'description':
          'A complete collection of duas in Bengali for daily Islamic practice.',
      'category': 'worship',
      "subTitle": "Make Dua",
      'premium': true,
      'is_png': false,
    },
  ];

  List<Map<String, dynamic>> get filteredItems {
    final authController = Get.find<AuthController>();
    final visibleItems = allItems
        .where((item) => item['premium'] != true || authController.isPremium)
        .toList();

    if (_searchQuery.value.isEmpty) return visibleItems;

    return visibleItems.where((item) {
      final label = easy.tr(item['label']).toLowerCase();
      final description = item['description'].toLowerCase();
      final category = item['category'].toLowerCase();
      final query = _searchQuery.value.toLowerCase();
      return label.contains(query) ||
          description.contains(query) ||
          category.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    // Reuse controller if PrayerScreen already created it, else create permanent
    _prayerController = Get.isRegistered<PrayerController>()
        ? Get.find<PrayerController>()
        : Get.put(PrayerController(), permanent: true);

    // Only fetch if prayer times not loaded yet
    if (_prayerController.prayerTimes.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prayerController.initLocationService();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final NavController navController = Get.isRegistered<NavController>()
      ? Get.find<NavController>()
      : Get.put(NavController());
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.bgColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Search Bar ──────────────────────────────────────
              Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isSearchExpanded.value ? 80 : 0,
                    child: _isSearchExpanded.value
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.containerColor(context),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: AppColors.greyBorder(context)
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) =>
                                        _searchQuery.value = value,
                                    decoration: InputDecoration(
                                      hintText:
                                          easy.tr('search_islamic_topics'),
                                      hintStyle: GoogleFonts.poppins(
                                        color: AppColors.greyText(context)
                                            .withValues(alpha: 0.7),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: AppColors.appbarText,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_searchQuery.value.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${filteredItems.length} ${easy.tr('results_found')}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.greyText(context),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  )),

              const SizedBox(height: 20),

              // ── Prayer Cards ────────────────────────────────────
              // ── Prayer Cards ────────────────────────────────────────────────────────────
              Obx(() {
                // Show shimmer while loading or times not yet fetched
                if (_prayerController.isLoading.value ||
                    _prayerController.prayerTimes.isEmpty) {
                  return const PrayerCardsShimmer();
                }

                final checkins = _prayerController.prayerCheckins;
                final reached = _prayerController.reachedPrayers.value;
                final times = _prayerController.prayerTimes;

                final prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
                final prayerNames = [
                  'Fajar',
                  'Dhuhr',
                  'Asar',
                  'Magrib',
                  'Isha'
                ];

                final prayers = List.generate(prayerKeys.length, (i) {
                  final key = prayerKeys[i];
                  final isReached = reached.contains(key);
                  final isChecked = checkins[key] ?? false;

                  PrayerStatus status;
                  if (!isReached) {
                    status = PrayerStatus.disabled;
                  } else if (isChecked) {
                    status = PrayerStatus.completed;
                  } else {
                    final currentIndex = prayerKeys.indexOf(key);
                    final nextKey = currentIndex < prayerKeys.length - 1
                        ? prayerKeys[currentIndex + 1]
                        : null;
                    final nextReached =
                        nextKey != null && reached.contains(nextKey);
                    status = nextReached
                        ? PrayerStatus.missed
                        : PrayerStatus.pending;
                  }

                  return PrayerItem(name: prayerNames[i], status: status);
                });

                // Health status
                // ── Health status: worst status across ALL reached prayers ──
                PrayerHealthStatus healthStatus = PrayerHealthStatus.good;

                for (final key in prayerKeys) {
                  // Skip prayers whose time hasn't arrived yet
                  if (!reached.contains(key)) continue;

                  final isChecked = checkins[key] ?? false;
                  final prayerTimeStr =
                      times.firstWhereOrNull((p) => p.key == key)?.time;
                  if (prayerTimeStr == null || prayerTimeStr.trim().isEmpty) {
                    continue;
                  }

                  DateTime? prayerDateTime;
                  try {
                    final parsed =
                        easy.DateFormat('HH:mm').parse(prayerTimeStr.trim());
                    final now = DateTime.now();
                    prayerDateTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      parsed.hour,
                      parsed.minute,
                    );
                  } catch (_) {
                    continue;
                  }

                  final status = getPrayerHealthStatus(
                    prayerTime: prayerDateTime,
                    isPrayed: isChecked,
                  );

                  // Keep the WORST status seen so far
                  if (prayerHealthSeverity(status) >
                      prayerHealthSeverity(healthStatus)) {
                    healthStatus = status;
                  }
                }

                return Column(
                  children: [
                    PrayerStreakCard(
                      streakDays: _prayerController.streakDays.value,
                      prayers: prayers,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to PrayerScreen when tapped
                        navController.changeTab(1);
                      },
                      child: PrayerHealthCard(
                        status: healthStatus,
                        nextPrayerName: _prayerController.nextPrayer.value,
                        timeRemainingObservable:
                            _prayerController.timeRemaining,
                      ),
                    ),
                  ],
                );
              }),

              ShowHomeNativeAdWidget(),

              // const SimpleCactusClock(
              //   size: 90,
              //   emojiAsset: 'assets/home/emoj.png',
              // ),
              // ── Grid ────────────────────────────────────────────
              Obx(() => AnimationLimiter(
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 170,
                      // childAspectRatio: 0.5,
                      children: List.generate(filteredItems.length, (index) {
                        final item = filteredItems[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          columnCount: 4,
                          duration: const Duration(milliseconds: 400),
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: GridItem(
                                subtitle: item['subTitle'] ?? '',
                                isPng: item['is_png'] ?? false,
                                svgPath: item['svg'] as String,
                                label: item['label'] as String,
                                onTap: () =>
                                    Get.to(() => item['screen'] as Widget)
                                        ?.then((v) {
                                  _backPressInterstitialAd.showAdOnBackPress();
                                }),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  )),

              const SizedBox(height: 20),

              // ── Search overflow button ───────────────────────────
              Obx(() =>
                  _searchQuery.value.isNotEmpty && filteredItems.length > 8
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => SearchResultsScreen(
                                    searchQuery: _searchQuery.value,
                                    searchResults: filteredItems,
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.appbarText,
                              foregroundColor: AppColors.buttonText,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${easy.tr('view_all_results')} (${filteredItems.length})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search Results Screen ──────────────────────────────────────────────────

class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;
  final List<Map<String, dynamic>> searchResults;

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
    required this.searchResults,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.bgColor(context),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back_ios, color: AppColors.appbarText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    easy.tr('search_results'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.appbarText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '"$searchQuery" - ${searchResults.length} results',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.greyText(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final item = searchResults[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 300),
            child: SlideAnimation(
              verticalOffset: 20.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: TouchRippleEffect(
                    onTap: () => Get.to(() => item['screen'] as Widget),
                    rippleColor: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.containerColor(context),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.greyBorder(context)
                                .withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.appbarText.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SvgPicture.asset(
                              item['svg'] as String,
                              height: 24,
                              width: 24,
                              colorFilter: ColorFilter.mode(
                                AppColors.appbarText,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  easy.tr(item['label'] as String),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blackText(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['description'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.greyText(context),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.appbarText
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.appbarText
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    item['category'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.appbarText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.greyText(context),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
