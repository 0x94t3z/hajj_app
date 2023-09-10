import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorSys {
  static const Color primary = Color.fromRGBO(42, 42, 42, 1);
  static const Color grey = Color.fromRGBO(158, 158, 158, 1);
  static const Color secoundry = Color.fromRGBO(198, 116, 27, 1);
  static const Color lightSecondary = Color.fromRGBO(226, 185, 141, 1);
  static const Color lightBlue = Color.fromRGBO(137, 183, 204, 1);
  static const Color darkBlue = Color.fromRGBO(68, 124, 142, 1);
  static const Color moreDarkBlue = Color.fromRGBO(30, 55, 70, 70);
  static const Color colorClock = Color.fromRGBO(51, 51, 51, 1);
}

TextStyle titleTextStyle() {
  return GoogleFonts.montserrat(
    color: ColorSys.primary,
    fontSize: 30,
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
  return GoogleFonts.poppins(
    color: color ?? ColorSys.grey,
    fontSize: fontSize ?? 20,
    fontWeight: fontWeight ?? FontWeight.w400,
  );
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
