import 'package:flutter/cupertino.dart';

class ButtonAnimationWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const ButtonAnimationWidget({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ButtonAnimationWidgetState createState() => _ButtonAnimationWidgetState();
}

class _ButtonAnimationWidgetState extends State<ButtonAnimationWidget>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;

  double _scaleTransformValue = 1;
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: clickAnimationDurationMillis),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _shrinkButtonSize() {
    if (!mounted) return;
    animationController.forward();
  }

  void _restoreButtonSize() {
    Future.delayed(
      const Duration(milliseconds: clickAnimationDurationMillis),
      () {
        if (!mounted) return; // widget may have been disposed by now
        animationController.reverse();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Future.delayed(
          const Duration(milliseconds: clickAnimationDurationMillis * 2),
          () {
            if (!mounted) return;
            widget.onTap.call();
          },
        );
        _shrinkButtonSize();
        _restoreButtonSize();
      },
      onTapDown: (_) => _shrinkButtonSize(),
      onTapCancel: _restoreButtonSize,
      child: Transform.scale(
        scale: _scaleTransformValue,
        child: widget.child,
      ),
    );
  }
}
