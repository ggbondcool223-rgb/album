import 'package:flutter/material.dart';
import '../models/template_animation.dart';

class AnimationHelper {
  static Widget buildAnimatedImage({
    required Widget child,
    required TemplateAnimationStyle style,
    required AnimationController controller,
    Duration? duration,
  }) {
    switch (style) {
      case TemplateAnimationStyle.fade:
        return FadeTransition(
          opacity: controller,
          child: child,
        );
      case TemplateAnimationStyle.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(controller),
          child: child,
        );
      case TemplateAnimationStyle.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(controller),
          child: child,
        );
      case TemplateAnimationStyle.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(controller),
          child: child,
        );
      case TemplateAnimationStyle.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(controller),
          child: child,
        );
      case TemplateAnimationStyle.zoomIn:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(controller),
          child: child,
        );
      case TemplateAnimationStyle.zoomOut:
        return ScaleTransition(
          scale: Tween<double>(begin: 1.5, end: 1.0).animate(controller),
          child: child,
        );
      case TemplateAnimationStyle.rotate:
        return RotationTransition(
          turns: Tween<double>(begin: 0.0, end: 1.0).animate(controller),
          child: child,
        );
      case TemplateAnimationStyle.flip:
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(controller.value * 3.14159),
              child: child,
            );
          },
          child: child,
        );
      case TemplateAnimationStyle.bounce:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.bounceOut,
          )),
          child: child,
        );
      case TemplateAnimationStyle.elastic:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            ),
          ),
          child: child,
        );
      case TemplateAnimationStyle.none:
        return child;
    }
  }

  static Widget buildAnimatedSubtitle({
    required Widget child,
    required TemplateAnimationStyle style,
    required AnimationController controller,
  }) {
    return buildAnimatedImage(
      child: child,
      style: style,
      controller: controller,
    );
  }

  static Widget buildAnimatedDanmaku({
    required Widget child,
    required TemplateAnimationStyle style,
    required AnimationController controller,
  }) {
    return buildAnimatedImage(
      child: child,
      style: style,
      controller: controller,
    );
  }

  static TemplateAnimationStyle parseAnimationStyle(String styleString) {
    final styleName = styleString.split('.').last;
    return TemplateAnimationStyle.values.firstWhere(
      (s) => s.toString().split('.').last == styleName,
      orElse: () => TemplateAnimationStyle.none,
    );
  }
}

