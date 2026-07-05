import 'package:flutter/material.dart';

class AppColors {
  // Colors that stay the same in both themes
  //static const Color appbarText = Color(0xffEDBA21);
  static const Color appbarText = Color(0xff2F9E92);
  static const Color wrongOption = Color(0xffFF9A9A);
  static const Color correctOption = Color(0xff5BD151);
  //static const Color buttonColor = Color(0xffEDBA21);
  static const Color buttonColor = Color(0xff2F9E92);
  static const Color buttonText = Color(0xffFFFFFF);
  static const Color indexColor = Color(0xff0F6F67);
  static const Color navbarText = Color(0xffFFFFFF);
  static const Color greyOption = Color(0xff7F7F7F);
  static const Color whiteText = Color(0xffFFFFFF);
  static const Color greenNeedle = Color(0xff2EB60C);
  static const Color darkMintGreen = Color(0xff0F6F67);
  static const Color greenTeal = Color(0xff2F9E92);
  static const Color cyanGreen = Color(0xff6EC8B8);
  static const Color premiumGradientStart = Color(0xFF28958B);
  static const Color premiumGradientEnd = Color(0xA8232F6A);


  // Private light theme colors
  static const Color _lightBgColor = Color(0xffFAF8F5);
  //static const Color _lightContainerColor = Color(0xffF9F2DF);
  static const Color _lightContainerColor = Color(0xffEDF7F6);
  static const Color _lightBlackText = Color(0xff000000);
  static const Color _lightGreyText = Color(0xff587677);
  static const Color _lightGreyBorder = Color(0xffF0EDE7);
  static const Color _lightBottomNavbar = Color(0xffFFFFFF);
  static const Color _lightGreyContainer = Color(0xffF5F3EE);
  static const Color _lightIconColor = Color(0xff414444);
  static const Color _lightGreyBar = Color(0xffDCDCDC);
  static const Color _lightGreyNeedle = Color(0xffD9D9D9);

  // Private dark theme colors
  static const Color _darkBgColor = Color(0xff1A1A1A);
  static const Color _darkContainerColor = Color(0xff2D2D2D);
  static const Color _darkBlackText = Color(0xffFFFFFF);
  static const Color _darkGreyText = Color(0xffB0B0B0);
  static const Color _darkGreyBorder = Color(0xff404040);
  static const Color _darkBottomNavbar = Color(0xff2D2D2D);
  static const Color _darkGreyContainer = Color(0xff2D2D2D);
  static const Color _darkIconColor = Color(0xffE0E0E0);
  static const Color _darkGreyBar = Color(0xff404040);
  static const Color _darkGreyNeedle = Color(0xff505050);

  // Context-aware getters
  static Color bgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBgColor
        : _lightBgColor;
  }

  static Color containerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkContainerColor
        : _lightContainerColor;
  }

  static Color blackText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBlackText
        : _lightBlackText;
  }

  static Color greyText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkGreyText
        : _lightGreyText;
  }

  static Color greyBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkGreyBorder
        : _lightGreyBorder;
  }

  static Color bottomNavbar(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBottomNavbar
        : _lightBottomNavbar;
  }

  static Color greyContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkGreyContainer
        : _lightGreyContainer;
  }

  static Color iconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkIconColor
        : _lightIconColor;
  }

  static Color greyBar(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkGreyBar
        : _lightGreyBar;
  }

  static Color greyNeedle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkGreyNeedle
        : _lightGreyNeedle;
  }

  // Themed method aliases for consistency with codebase usage
  static Color bgColorThemed(BuildContext context) => bgColor(context);
  static Color containerColorThemed(BuildContext context) => containerColor(context);
  static Color blackTextThemed(BuildContext context) => blackText(context);
  static Color greyTextThemed(BuildContext context) => greyText(context);
  static Color greyBorderThemed(BuildContext context) => greyBorder(context);
  static Color greyContainerThemed(BuildContext context) => greyContainer(context);
  static Color greyNeedleThemed(BuildContext context) => greyNeedle(context);
  static Color iconColorThemed(BuildContext context) => iconColor(context);
}
