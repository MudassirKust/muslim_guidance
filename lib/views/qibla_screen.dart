import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/controllers/prayer_controller.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import '../controllers/qibla_controller.dart';
import 'constants/appcolors.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'widgets/banner_ad_widget.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late QiblaController controller;
  late PrayerController prayercontroller;

  @override
  void initState() {
    super.initState();
    prayercontroller = Get.put(PrayerController());
    controller = Get.put(QiblaController());
    // Trigger location permission request when user accesses Qibla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      prayercontroller.initLocationService();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.appbarText),
            const SizedBox(height: 10),
            Center(
              child: Obx(() => Text(
                    controller.loadingMessage.value,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.appbarText,
                    ),
                  )),
            )
          ],
        );
      }

      return Scaffold(
          backgroundColor: AppColors.bgColorThemed(context),
          appBar: AppBar(
            backgroundColor: AppColors.bgColorThemed(context),
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  easy.tr("qibla_direction"),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.appbarText,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  easy.tr("qibla_description"),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.greyTextThemed(context),
                  ),
                )
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 500),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          //height: 72,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.greyContainerThemed(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.greyBorderThemed(context),
                                width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AppImages.location),
                                  const SizedBox(width: 6),
                                  Text(
                                    easy.tr("your_location"),
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color:
                                            AppColors.greyTextThemed(context)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${easy.tr("latitude")}: ${prayercontroller.latitude.value.toStringAsFixed(4)},",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color:
                                            AppColors.greyTextThemed(context)),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "${easy.tr("longitude")} ${prayercontroller.longitude.value.toStringAsFixed(4)}",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color:
                                            AppColors.greyTextThemed(context)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Column(
                          children: [
                            SizedBox(height: 8),
                            BannerAdWidget(),
                            SizedBox(height: 8),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.containerColorThemed(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.greyBorderThemed(context),
                                width: 1),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Obx(
                                    () => CircleAvatar(
                                      backgroundColor:
                                          AppColors.bgColorThemed(context),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.vibration,
                                          color: controller.isVibrationOn.value
                                              ? AppColors.appbarText
                                              : AppColors.greyNeedleThemed(
                                                  context),
                                        ),
                                        onPressed: controller.toggleVibration,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  )
                                ],
                              ),
                              SvgPicture.asset(
                                AppImages.arrowQibla,
                                colorFilter: ColorFilter.mode(
                                  controller.isAlignedWithQibla
                                      ? AppColors.greenNeedle
                                      : AppColors.greyNeedleThemed(context),
                                  BlendMode.srcIn,
                                ),
                              ),
                              // Icon(
                              //   Icons.arrow_drop_down,
                              //   color: controller.isAlignedWithQibla ? AppColors.greenNeedle : AppColors.greyNeedle ,
                              //   size: 50,
                              // ),
                              const SizedBox(
                                height: 10,
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    //width: 200,
                                    //height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.greenTeal
                                              .withValues(alpha: 0.5),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Transform.rotate(
                                        angle: -controller.heading * (pi / 180),
                                        // child: SvgPicture.asset(
                                        //   AppImages.compass,
                                        // )

                                        child: Image.asset(
                                          'assets/images/compass_image.png',
                                        )),
                                  ),
                                  if (controller.hasCompass.value)
                                    Transform.rotate(
                                        angle: -controller.qiblaRotationAngle *
                                            (pi / 180),
                                        child: controller.isAlignedWithQibla
                                            ? SvgPicture.asset(
                                                AppImages.greenPointer,
                                                //height: 100,
                                                //width: 100,
                                              )
                                            : SvgPicture.asset(
                                                AppImages.pointer,
                                                //height: 100,
                                                //width: 100,
                                              ))
                                  else
                                    const Text(
                                      "Compass not available on this device",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                easy.tr("compass_hint"),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.greyTextThemed(context),
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),

                              Text(
                                easy.tr("qibla_direction"),
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blackTextThemed(context)),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${controller.qiblaDirection.value.toStringAsFixed(1)}°  (${easy.tr("clockwise_from_north")})",
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blackTextThemed(context)),
                              ),
                              // const SizedBox(height: 6),
                              // Text(
                              //   controller.compassDirection.value,
                              //   style: const TextStyle(color: Colors.grey),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
    });
  }

  // static const compassStyle = TextStyle(
  //   fontWeight: FontWeight.bold,
  //   fontSize: 14,
  //   color: Colors.grey,
  // );
}
