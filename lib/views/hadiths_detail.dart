import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/hadith_controller.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';

class HadithsDetail extends StatelessWidget {
  final String bookId;
  final int tag;
  final HadithController _controller = Get.put(HadithController());

  HadithsDetail({super.key, required this.bookId, required this.tag});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _controller.loadHadithIfNeeded(bookId),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: AppColors.bgColorThemed(context),
          appBar: AppBar(
            backgroundColor: AppColors.appbarText,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 30,
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
              ],
            ),
          ),
          body: Obx(() {
            if (_controller.isLoading.value) {
              return Center(
                  child:
                      CircularProgressIndicator(color: AppColors.appbarText));
            }

            final book = _controller.getBookById(bookId);
            if (book == null) {
              return Center(
                child: Text(
                  'Hadith not found',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.appbarText,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 500),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 40.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Hero(
                            tag: tag,
                            child: Text(
                              _controller.localized(book.title),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                color: AppColors.appbarText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _controller.localized(book.content),
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.blackTextThemed(context),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ));
          }),
        );
      },
    );
  }
}
