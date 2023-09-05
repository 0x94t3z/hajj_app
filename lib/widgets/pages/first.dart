import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:hajj_app/helpers/styles.dart';

class FirstWidget extends StatelessWidget {
  const FirstWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HijriCalendar today = HijriCalendar.now();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding:
                    const EdgeInsets.all(18.0), // Adjust the padding as needed
                child: Text(
                  '${today.fullDate()} H.',
                  style: textStyle(fontSize: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 100.0), // Add spacing between text and clock
            Center(
              child: AnalogClock(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(width: 4.0, color: ColorSys.primary),
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 7,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                datetime: DateTime.now(),
                isLive: true,
                hourHandColor: ColorSys.primary,
                minuteHandColor: ColorSys.primary,
                secondHandColor: Colors.red,
                numberColor: ColorSys.primary,
                showNumbers: true,
                showTicks: true,
                textScaleFactor: 1.2,
                showDigitalClock: true,
                digitalClockColor: ColorSys.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
