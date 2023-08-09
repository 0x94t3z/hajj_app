import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/colors.dart';
import 'package:hajj_app/helpers/strings_intro.dart';
import 'package:hajj_app/screens/login/auth.dart';
import 'package:hajj_app/widgets/onboarding/onboarding_page.dart';
import 'package:hajj_app/screens/hajj_feature/home.dart';

class Introduction extends StatefulWidget {
  const Introduction({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _IntroductionState createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
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

  // Navigate to Home Screen
  void navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // Navigate to Login Screen
  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 20),
            child: GestureDetector(
              onTap: navigateToLogin,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: ColorSys.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
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
                image: 'assets/images/one.png',
                title: Strings.stepOneTitle,
                content: Strings.stepOneContent,
              ),
              OnboardingPage(
                image: 'assets/images/two.png',
                title: Strings.stepTwoTitle,
                content: Strings.stepTwoContent,
              ),
              OnboardingPage(
                image: 'assets/images/three.png',
                title: Strings.stepThreeTitle,
                content: Strings.stepThreeContent,
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
        color: ColorSys.darkBlue,
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
