import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upgrader/upgrader.dart';
import 'package:islamlearning/views/constants/appcolors.dart';

class ThemedUpgradeAlert extends UpgradeAlert {
  ThemedUpgradeAlert({
    super.key,
    super.upgrader,
    super.barrierDismissible,
    super.showIgnore = false,
    super.showLater = true,
    super.child,
  });

  @override
  UpgradeAlertState createState() => _ThemedUpgradeAlertState();
}

class _ThemedUpgradeAlertState extends UpgradeAlertState {
  @override
  void checkVersion({required BuildContext context}) {
    final shouldDisplay = widget.upgrader.shouldDisplayUpgrade();
    if (shouldDisplay) {
      displayed = true;
      final body = easy.tr(
        'update_body',
        namedArgs: {
          'app_name': widget.upgrader.appName(),
          'store_version': widget.upgrader.currentAppStoreVersion ?? '',
          'installed_version': widget.upgrader.currentInstalledVersion ?? '',
        },
      );

      Future.delayed(Duration.zero, () {
        showTheDialog(
          key: widget.dialogKey ?? const Key('upgrader_alert_dialog'),
          // ignore: use_build_context_synchronously
          context: context,
          title: easy.tr('update_available'),
          message: body,
          releaseNotes: null,
          barrierDismissible: widget.barrierDismissible,
          messages: UpgraderMessages(),
        );
      });
    }
  }

  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    widget.upgrader.saveLastAlerted();

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => PopScope(
        canPop: onCanPop(),
        child: _UpdateDialog(
          key: key,
          title: title ?? easy.tr('update_available'),
          message: message,
          showLater: widget.showLater && !widget.upgrader.blocked(),
          onLater: () => onUserLater(ctx, true),
          onUpdate: () => onUserUpdated(ctx, !widget.upgrader.blocked()),
        ),
      ),
    );
  }
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({
    super.key,
    required this.title,
    required this.message,
    required this.showLater,
    required this.onLater,
    required this.onUpdate,
  });

  final String title;
  final String message;
  final bool showLater;
  final VoidCallback onLater;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Card body — pushed down to leave room for the floating icon
          Container(
            margin: const EdgeInsets.only(top: 40),
            decoration: BoxDecoration(
              color: AppColors.containerColorThemed(context),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackTextThemed(context),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greyTextThemed(context),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      easy.tr('update_now'),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (showLater) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onLater,
                    child: Text(
                      easy.tr('update_later'),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.greyText(context)
                            : AppColors.greenTeal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Floating icon circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.cyanGreen, AppColors.darkMintGreen],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.greenTeal.withAlpha(80),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.system_update_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }
}
