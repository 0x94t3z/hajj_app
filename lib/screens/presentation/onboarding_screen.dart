import 'package:flutter/material.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/core/constants/onboarding_strings.dart';
import 'package:hajj_app/widgets/onboarding/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Navigate to Login Screen
  void navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSys.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorSys.surface,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 20),
            child: GestureDetector(
              onTap: navigateToLogin,
              child: Text(
                'Skip',
                style: textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorSys.darkBlue,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            onPageChanged: (int page) {
              setState(() {
                currentIndex = page;
              });
            },
            controller: _pageController,
            children: <Widget>[
              OnboardingPage(
                image: OnboardingStrings.stepOneImage,
                title: OnboardingStrings.stepOneTitle,
                content: OnboardingStrings.stepOneContent,
              ),
              OnboardingPage(
                image: OnboardingStrings.stepTwoImage,
                title: OnboardingStrings.stepTwoTitle,
                content: OnboardingStrings.stepTwoContent,
              ),
              OnboardingPage(
                image: OnboardingStrings.stepThreeImage,
                title: OnboardingStrings.stepThreeTitle,
                content: OnboardingStrings.stepThreeContent,
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildIndicator(),
            ),
          )
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 30 : 6,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: isActive ? ColorSys.darkBlue : ColorSys.primarySoft,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  List<Widget> _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 3; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }
    return indicators;
  }
}
