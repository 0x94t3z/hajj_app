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
                  border: Border.all(width: 2.0, color: Colors.black),
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                datetime: DateTime.now(),
                isLive: true,
                hourHandColor: Colors.black,
                minuteHandColor: Colors.black,
                secondHandColor: Colors.red,
                numberColor: Colors.black,
                showNumbers: true,
                showTicks: true,
                textScaleFactor: 1.0,
                showDigitalClock: true,
                digitalClockColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
