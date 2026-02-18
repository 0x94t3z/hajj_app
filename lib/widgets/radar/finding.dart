import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/services/user_service.dart';

class FindingWidget extends StatefulWidget {
  const FindingWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FindingWidgetState createState() => _FindingWidgetState();
}

class _FindingWidgetState extends State<FindingWidget>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final animationsMap = {
    'textOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 500.ms),
        MoveEffect(
          curve: Curves.easeOut,
          delay: 500.ms,
          duration: 400.ms,
          begin: const Offset(0.0, 100.0),
          end: const Offset(0.0, 0.0),
        ),
        BlurEffect(
          curve: Curves.easeOut,
          delay: 500.ms,
          duration: 400.ms,
          begin: const Offset(20.0, 20.0),
          end: const Offset(0.0, 0.0),
        ),
        FadeEffect(
          curve: Curves.easeOut,
          delay: 500.ms,
          duration: 400.ms,
          begin: 0.0,
          end: 1.0,
        ),
      ],
    ),
    'containerOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 550.ms),
        MoveEffect(
          curve: Curves.easeOut,
          delay: 550.ms,
          duration: 400.ms,
          begin: const Offset(0.0, 100.0),
          end: const Offset(0.0, 0.0),
        ),
        BlurEffect(
          curve: Curves.easeOut,
          delay: 550.ms,
          duration: 400.ms,
          begin: const Offset(20.0, 20.0),
          end: const Offset(0.0, 0.0),
        ),
        FadeEffect(
          curve: Curves.easeOut,
          delay: 550.ms,
          duration: 400.ms,
          begin: 0.0,
          end: 1.0,
        ),
      ],
    ),
    'containerOnPageLoadAnimation2': AnimationInfo(
      loop: true,
      reverse: true,
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        BlurEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 2000.ms,
          begin: const Offset(20.0, 20.0),
          end: const Offset(60.0, 60.0),
        ),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 2000.ms,
          begin: 0.295,
          end: 0.655,
        ),
        ScaleEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 2000.ms,
          begin: const Offset(1.0, 1.0),
          end: const Offset(4.0, 4.0),
        ),
      ],
    ),
    'containerOnPageLoadAnimation3': AnimationInfo(
      loop: true,
      reverse: true,
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 3000.ms),
        ScaleEffect(
          curve: Curves.easeInOut,
          delay: 7000.ms,
          duration: 1500.ms,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.3, 1.3),
        ),
        BlurEffect(
          curve: Curves.easeInOut,
          delay: 10000.ms,
          duration: 1500.ms,
          begin: const Offset(0.0, 0.0),
          end: const Offset(4.0, 4.0),
        ),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 9000.ms,
          duration: 540.ms,
          begin: 0.0,
          end: 1.0,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 3000.ms,
          duration: 1500.ms,
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 12000.ms,
          duration: 600.ms,
          begin: 1.0,
          end: 0.0,
        ),
      ],
    ),
    'containerOnPageLoadAnimation4': AnimationInfo(
      loop: true,
      reverse: true,
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 3000.ms),
        ScaleEffect(
          curve: Curves.easeInOut,
          delay: 3000.ms,
          duration: 1500.ms,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.3, 1.3),
        ),
        BlurEffect(
          curve: Curves.easeInOut,
          delay: 6000.ms,
          duration: 1500.ms,
          begin: const Offset(0.0, 0.0),
          end: const Offset(4.0, 4.0),
        ),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 3500.ms,
          duration: 540.ms,
          begin: 0.0,
          end: 1.0,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 6000.ms,
          duration: 1500.ms,
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 7000.ms,
          duration: 600.ms,
          begin: 1.0,
          end: 0.0,
        ),
      ],
    ),
    'iconButtonOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 200.ms),
        ScaleEffect(
          curve: Curves.easeOut,
          delay: 200.ms,
          duration: 400.ms,
          begin: const Offset(2.0, 2.0),
          end: const Offset(1.0, 1.0),
        ),
        FadeEffect(
          curve: Curves.easeOut,
          delay: 200.ms,
          duration: 400.ms,
          begin: 0.0,
          end: 1.0,
        ),
        BlurEffect(
          curve: Curves.easeOut,
          delay: 200.ms,
          duration: 400.ms,
          begin: const Offset(10.0, 10.0),
          end: const Offset(0.0, 0.0),
        ),
        MoveEffect(
          curve: Curves.easeOut,
          delay: 200.ms,
          duration: 400.ms,
          begin: const Offset(0.0, 70.0),
          end: const Offset(0.0, 0.0),
        ),
      ],
    ),
  };

  late AnimationController _controller;
  String buttonLabel = 'Find Officers';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 15000),
    );

    // Add a listener to the controller to detect when the animations are done.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation is completed, navigate to MapScreen
        Navigator.of(context).pushReplacementNamed('/finding');
      }
    });

    // Set the button label
    _setButtonLabel();
    // Start the animations when the widget is initialized
    _startAnimations();
  }

  void _startAnimations() {
    // Start your animations here using _controller.forward()
    animationsMap['textOnPageLoadAnimation']!.controller = _controller;
    animationsMap['containerOnPageLoadAnimation1']!.controller = _controller;
    // Add more animations as needed

    // Start all animations
    _controller.forward();
  }

  bool _isPetugasRole(String role) {
    final normalizedRole = role.trim().toUpperCase();
    return UserService.validPetugasHajiRoles
        .any((value) => value.toUpperCase() == normalizedRole);
  }

  Future<void> _setButtonLabel() async {
    try {
      final role =
          await _userService.fetchCurrentUserRole(defaultRole: 'Jemaah Haji');
      final isPetugas = _isPetugasRole(role);
      if (!mounted) return;
      setState(() {
        buttonLabel = isPetugas ? 'Find Pilgrims' : 'Find Officers';
      });
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = math.max(430.0, math.min(screenHeight * 0.66, 620.0));

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 24.0),
          child: SizedBox(
            height: sheetHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorSys.backgroundMap,
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: ColorSys.backgroundMap,
                    width: 2.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 16.0, 0.0, 0.0),
                            child: Text(
                              buttonLabel,
                              style: textStyle(
                                  fontSize: 20,
                                  color: ColorSys.darkBlue,
                                  fontWeight: FontWeight.bold),
                            ).animateOnPageLoad(
                                animationsMap['textOnPageLoadAnimation']!),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Container(
                              width: 60.0,
                              height: 3.0,
                              decoration: BoxDecoration(
                                color: ColorSys.cirlceMap,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation1']!),
                          ),
                          const SizedBox(height: 20.0),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final radarSize = math.min(
                                      constraints.maxWidth,
                                      constraints.maxHeight,
                                    ) *
                                    0.88;
                                final middleCircleSize = radarSize * 0.70;
                                final innerCircleSize = radarSize * 0.44;
                                final pulseSize = radarSize * 0.16;
                                final blipSize =
                                    math.max(radarSize * 0.05, 14.0);

                                return Center(
                                  child: SizedBox(
                                    width: radarSize,
                                    height: radarSize,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: radarSize,
                                          height: radarSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: ColorSys.cirlceMap,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: middleCircleSize,
                                          height: middleCircleSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: ColorSys.cirlceMap,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: innerCircleSize,
                                          height: innerCircleSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: ColorSys.cirlceMap,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: pulseSize,
                                          height: pulseSize,
                                          decoration: const BoxDecoration(
                                            color: ColorSys.radarMap,
                                            shape: BoxShape.circle,
                                          ),
                                        ).animateOnPageLoad(animationsMap[
                                            'containerOnPageLoadAnimation2']!),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              -0.3, -0.25),
                                          child: Container(
                                            width: blipSize,
                                            height: blipSize,
                                            decoration: const BoxDecoration(
                                              color: ColorSys.radarMap,
                                              shape: BoxShape.circle,
                                            ),
                                          ).animateOnPageLoad(animationsMap[
                                              'containerOnPageLoadAnimation3']!),
                                        ),
                                        Align(
                                          alignment: const AlignmentDirectional(
                                              0.45, -0.5),
                                          child: Container(
                                            width: blipSize,
                                            height: blipSize,
                                            decoration: const BoxDecoration(
                                              color: ColorSys.radarMap,
                                              shape: BoxShape.circle,
                                            ),
                                          ).animateOnPageLoad(animationsMap[
                                              'containerOnPageLoadAnimation4']!),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 10.0,
                        right: 4.0,
                        child: IconButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 32.0,
                          ),
                        ).animateOnPageLoad(
                            animationsMap['iconButtonOnPageLoadAnimation']!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when not needed
    super.dispose();
  }
}
