import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hajj_app/helpers/styles.dart';

class SecondWidget extends StatelessWidget {
  const SecondWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String locale = 'en';

    HijriCalendar today = HijriCalendar.now();
    HijriCalendar.setLocal(locale);

    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 24.0,
                backgroundImage: NetworkImage(
                  'https://avatars.githubusercontent.com/u/52822242?v=4', // Profile image URL
                ),
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, Muhamad Taopik!',
                    style: textStyle(fontSize: 16.0),
                  ),
                  const SizedBox(
                      height: 40.0), // Add spacing between text and date/time
                  Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today is',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          today.getDayName(),
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Current Islamic time:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          today.fullDate(),
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
