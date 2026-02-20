import 'package:flutter/material.dart';
import 'package:hajj_app/core/theme/app_style.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String content;
  final bool reverse;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.content,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (!reverse)
            Column(
              children: <Widget>[
                SizedBox(
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorSys.primaryTint,
                        ),
                      ),
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorSys.primarySoft,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset(image),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            )
          else
            const SizedBox(),
          Text(
            title,
            style: textStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: ColorSys.darkBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            textAlign: TextAlign.center,
            style: contentTextStyle(
              fontSize: 14,
              color: ColorSys.textSecondary,
            ),
          ),
          if (reverse)
            Column(
              children: <Widget>[
                const SizedBox(height: 20),
                SizedBox(
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorSys.primaryTint,
                        ),
                      ),
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorSys.primarySoft,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset(image),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
