import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const String _appFontFamily = 'Montserrat';

class ColorSys {
  // Brand anchor
  static const Color darkBlue = Color.fromRGBO(71, 131, 149, 1);
  static const Color lightBlue = Color.fromRGBO(163, 192, 201, 1);

  // Core palette (derived from darkBlue)
  static const Color primary = darkBlue;
  static const Color primarySoft = Color(0xFFBFD6DD);
  static const Color primaryTint = Color(0xFFDCE9EE);
  static const Color surface = Color(0xFFF7FAFB);
  static const Color surfaceAlt = Color(0xFFF1F5F6);
  static const Color border = Color(0xFFDFE9EC);
  static const Color textPrimary = Color(0xFF20323B);
  static const Color textSecondary = Color(0xFF5F7C86);
  static const Color info = darkBlue;
  static const Color success = Color(0xFF2F8F7A);
  static const Color warning = Color(0xFFE0A64B);
  static const Color error = Color(0xFFD46363);

  // Legacy aliases (kept for compatibility)
  static const Color lightPrimary = Color.fromRGBO(51, 51, 51, 1);
  static const Color grey = Color.fromRGBO(158, 158, 158, 1);
  static const Color moreDarkBlue = Color.fromRGBO(30, 55, 70, 70);
  static const Color backgroundMap = Color.fromRGBO(236, 231, 228, 1);
  static const Color cirlceMap = Color.fromRGBO(225, 219, 215, 1);
  static const Color radarMap = Color.fromRGBO(163, 192, 201, 1);

  // Shared navigation-direction palette (maps.dart + navigation.dart)
  static const Color navigationPanelPrimary = Color(0xFF3E6EF0);
  static const Color navigationPanelSecondary = Color(0xFF2A4FB5);
  static const Color navigationDockBackground = Color(0xCC0E131E);
  static const Color navigationDockButton = Color(0xFF131823);
  static const Color navigationRoutePrimary = Color(0xFF74C1FF);
  static const Color navigationRouteBorder = Color(0xFF2D6CFF);
  static const Color navigationDanger = Color(0xFFFF4A57);
}

TextStyle titleTextStyle() {
  return const TextStyle(
    fontFamily: _appFontFamily,
    color: ColorSys.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
}

TextStyle contentTextStyle({Color? color, double? fontSize}) {
  return TextStyle(
    fontFamily: _appFontFamily,
    color: color ?? ColorSys.textSecondary,
    fontSize: fontSize ?? 18,
    fontWeight: FontWeight.w400,
  );
}

TextStyle textStyle({double? fontSize, Color? color, FontWeight? fontWeight}) {
  return TextStyle(
    fontFamily: _appFontFamily,
    color: color ?? ColorSys.textPrimary,
    fontSize: fontSize ?? 20,
    fontWeight: fontWeight ?? FontWeight.w400,
  );
}

// Flutter Flow Animation
enum AnimationTrigger {
  onPageLoad,
  onActionTrigger,
}

class AnimationInfo {
  AnimationInfo({
    required this.trigger,
    required this.effects,
    this.loop = false,
    this.reverse = false,
    this.applyInitialState = true,
  });
  final AnimationTrigger trigger;
  final List<Effect<dynamic>> effects;
  final bool applyInitialState;
  final bool loop;
  final bool reverse;
  late AnimationController controller;
}

void createAnimation(AnimationInfo animation, TickerProvider vsync) {
  final newController = AnimationController(vsync: vsync);
  animation.controller = newController;
}

void setupAnimations(Iterable<AnimationInfo> animations, TickerProvider vsync) {
  for (var animation in animations) {
    createAnimation(animation, vsync);
  }
}

extension AnimatedWidgetExtension on Widget {
  Widget animateOnPageLoad(AnimationInfo animationInfo) => Animate(
      effects: animationInfo.effects,
      child: this,
      onPlay: (controller) => animationInfo.loop
          ? controller.repeat(reverse: animationInfo.reverse)
          : null,
      onComplete: (controller) => !animationInfo.loop && animationInfo.reverse
          ? controller.reverse()
          : null);

  Widget animateOnActionTrigger(
    AnimationInfo animationInfo, {
    bool hasBeenTriggered = false,
  }) =>
      hasBeenTriggered || animationInfo.applyInitialState
          ? Animate(
              controller: animationInfo.controller,
              autoPlay: false,
              effects: animationInfo.effects,
              child: this)
          : this;
}

class TiltEffect extends Effect<Offset> {
  const TiltEffect({
    Duration? delay,
    Duration? duration,
    Curve? curve,
    Offset? begin,
    Offset? end,
  }) : super(
          delay: delay,
          duration: duration,
          curve: curve,
          begin: begin ?? const Offset(0.0, 0.0),
          end: end ?? const Offset(0.0, 0.0),
        );

  @override
  Widget build(
    BuildContext context,
    Widget child,
    AnimationController controller,
    EffectEntry entry,
  ) {
    Animation<Offset> animation = buildAnimation(controller, entry);
    return getOptimizedBuilder<Offset>(
      animation: animation,
      builder: (_, __) => Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(animation.value.dx)
          ..rotateY(animation.value.dy),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// theme.dart

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: ColorSys.darkBlue,
  colorScheme: const ColorScheme.dark(
    primary: ColorSys.darkBlue,
    secondary: Colors
        .white, // Change this to your desired secondary color in dark mode
  ),
  // Add more properties like text styles, fonts, etc. as needed
);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: ColorSys.darkBlue,
  scaffoldBackgroundColor: ColorSys.surface,
  colorScheme: const ColorScheme.light(
    primary: ColorSys.darkBlue,
    secondary: ColorSys.lightBlue,
    surface: ColorSys.surface,
    onPrimary: Colors.white,
    onSurface: ColorSys.textPrimary,
  ),
  // Add more properties like text styles, fonts, etc. as needed
);
