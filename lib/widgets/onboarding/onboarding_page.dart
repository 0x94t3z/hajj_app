import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/colors.dart';

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
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (!reverse)
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(image),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            )
          else
            const SizedBox(),
          Text(
            title,
            style: TextStyle(
              color: ColorSys.primary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorSys.grey,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (reverse)
            Column(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.asset(image),
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
