import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorSys {
  static const Color primary = Color.fromRGBO(42, 42, 42, 1);
  static const Color grey = Color.fromRGBO(158, 158, 158, 1);
  static const Color secoundry = Color.fromRGBO(198, 116, 27, 1);
  static const Color lightSecondary = Color.fromRGBO(226, 185, 141, 1);
  static const Color darkBlue = Color.fromRGBO(69, 125, 143, 1);
  static const Color moreDarkBlue = Color.fromRGBO(30, 55, 70, 70);
}

TextStyle titleTextStyle() {
  return GoogleFonts.montserrat(
    color: ColorSys.primary,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
}

TextStyle contentTextStyle() {
  return GoogleFonts.poppins(
    color: ColorSys.grey,
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );
}

TextStyle textStyle({double? fontSize}) {
  return GoogleFonts.poppins(
    color: ColorSys.grey,
    fontSize: fontSize ?? 20,
    fontWeight: FontWeight.w400,
  );
}
