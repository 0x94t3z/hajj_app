import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ColorSys {
  static const Color primary = Color.fromRGBO(42, 42, 42, 1);
  static const Color lightPrimary = Color.fromRGBO(51, 51, 51, 1);
  static const Color grey = Color.fromRGBO(158, 158, 158, 1);
  static const Color lightBlue = Color.fromRGBO(163, 192, 201, 1);
  static const Color darkBlue = Color.fromRGBO(71, 131, 149, 1);
  static const Color moreDarkBlue = Color.fromRGBO(30, 55, 70, 70);
}

TextStyle titleTextStyle() {
  return GoogleFonts.montserrat(
    color: ColorSys.primary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
}

TextStyle contentTextStyle({Color? color, double? fontSize}) {
  return GoogleFonts.poppins(
    color: color ?? ColorSys.grey,
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );
}

TextStyle textStyle({double? fontSize, Color? color, FontWeight? fontWeight}) {
  return GoogleFonts.montserrat(
    color: color ?? ColorSys.grey,
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
  animations.forEach((animation) => createAnimation(animation, vsync));
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
  primaryColor: const Color.fromRGBO(69, 125, 143, 1), // Dark blue color
  colorScheme: const ColorScheme.dark(
    primary: Color.fromRGBO(69, 125, 143, 1), // Dark blue color
    secondary: Colors
        .white, // Change this to your desired secondary color in dark mode
  ),
  // Add more properties like text styles, fonts, etc. as needed
);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor:
      Colors.white, // Change this to your desired primary color in light mode
  colorScheme: const ColorScheme.light(
    primary:
        Colors.white, // Change this to your desired primary color in light mode
    secondary: Color.fromRGBO(69, 125, 143, 1), // Dark blue color
  ),
  // Add more properties like text styles, fonts, etc. as needed
);
