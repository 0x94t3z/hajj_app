import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hajj_app/models/users.dart';

class FindingWidget extends StatefulWidget {
  const FindingWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FindingWidgetState createState() => _FindingWidgetState();
}

class _FindingWidgetState extends State<FindingWidget>
    with SingleTickerProviderStateMixin {
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

  Future<void> _setButtonLabel() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Map<String, List<UserModel>> groupedUsers =
            await fetchModelsFromFirebase();

        List<UserModel> allUsers = [
          ...groupedUsers['jemaahHaji'] ?? [],
          ...groupedUsers['petugasHaji'] ?? []
        ];

        final currentUserModel =
            allUsers.firstWhere((user) => user.userId == currentUser.uid,
                orElse: () => UserModel(
                      userId: '',
                      name: '',
                      roles: '',
                      distance: '',
                      duration: '',
                      imageUrl: '',
                      latitude: 0.0,
                      longitude: 0.0,
                    ));

        setState(() {
          buttonLabel =
              groupedUsers['jemaahHaji']?.contains(currentUserModel) == true
                  ? 'Find Officers'
                  : 'Find Pilgrims';
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
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
                padding: const EdgeInsets.all(16.0),
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
                        // const SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 08.0, 0.0, 0.0),
                          child: Container(
                            width: 60.0,
                            height: 3.0,
                            decoration: BoxDecoration(
                              color: ColorSys.cirlceMap,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ).animateOnPageLoad(
                              animationsMap['containerOnPageLoadAnimation1']!),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 500.0,
                          child: Stack(
                            alignment: const Alignment(0.0, 0.0),
                            children: [
                              Container(
                                width: 200.0,
                                height: 200.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorSys.cirlceMap,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              Container(
                                width: 300.0,
                                height: 300.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorSys.cirlceMap,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorSys.cirlceMap,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: const BoxDecoration(
                                  color: ColorSys.radarMap,
                                  shape: BoxShape.circle,
                                ),
                              ).animateOnPageLoad(animationsMap[
                                  'containerOnPageLoadAnimation2']!),
                              Align(
                                alignment:
                                    const AlignmentDirectional(-0.3, -0.25),
                                child: Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: const BoxDecoration(
                                    color: ColorSys.radarMap,
                                    shape: BoxShape.circle,
                                  ),
                                ).animateOnPageLoad(animationsMap[
                                    'containerOnPageLoadAnimation3']!),
                              ),
                              Align(
                                alignment:
                                    const AlignmentDirectional(0.45, -0.5),
                                child: Container(
                                  width: 16.0,
                                  height: 16.0,
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
                      ],
                    ),
                    Align(
                      alignment: const AlignmentDirectional(1.0, -1.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: ColorSys.moreDarkBlue,
                          backgroundColor: ColorSys.darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24.0,
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
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when not needed
    super.dispose();
  }
}
