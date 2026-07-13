import 'package:flutter/material.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class HomeClockTab extends StatefulWidget {
  const HomeClockTab({Key? key}) : super(key: key);

  @override
  State<HomeClockTab> createState() => _HomeClockTabState();
}

class _HomeClockTabState extends State<HomeClockTab> {
  static bool _timeZoneInitialized = false;
  static const Map<int, String> _hijriDayNamesId = {
    1: 'Senin',
    2: 'Selasa',
    3: 'Rabu',
    4: 'Kamis',
    5: 'Jumat',
    6: 'Sabtu',
    7: 'Minggu',
  };
  static const Map<int, String> _hijriMonthNamesId = {
    1: 'Muharram',
    2: 'Safar',
    3: 'Rabiul Awal',
    4: 'Rabiul Akhir',
    5: 'Jumadil Awal',
    6: 'Jumadil Akhir',
    7: 'Rajab',
    8: 'Syaban',
    9: 'Ramadan',
    10: 'Syawal',
    11: 'Zulkaidah',
    12: 'Zulhijah',
  };

  @override
  void initState() {
    super.initState();
    if (!_timeZoneInitialized) {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC'));
      _timeZoneInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    HijriCalendar today = HijriCalendar.now(); // Get current date in Hijri
    final hijriDateText = _formatHijriDate(today);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    '$hijriDateText H.',
                    style: textStyle(fontSize: 18.0, color: ColorSys.darkBlue),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              Center(
                child: AnalogClock(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  datetime: DateTime.now(),
                  isLive: true,
                  hourHandColor: Colors.white,
                  minuteHandColor: Colors.white,
                  numberColor: Colors.white,
                  secondHandColor: Colors.red,
                  showSecondHand: true,
                  showNumbers: true,
                  showTicks: false,
                  textScaleFactor: 1.2,
                  showDigitalClock: false,
                  digitalClockColor: Colors.white,
                ),
              ),
              const SizedBox(height: 70.0),
              _buildCountryWidget(
                country: 'Arab Saudi',
                city: 'Makkah',
                timeZone: 'Asia/Riyadh',
              ),
              const SizedBox(height: 25.0),
              _buildCountryWidget(
                country: 'Indonesia',
                city: 'Bandung',
                timeZone: 'Asia/Jakarta',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatHijriDate(HijriCalendar date) {
    final dayName = _hijriDayNamesId[date.wkDay] ?? '';
    final monthName = _hijriMonthNamesId[date.hMonth] ?? date.longMonthName;
    final day = date.hDay;
    final year = date.hYear;
    return '$dayName, $day $monthName $year';
  }

  Widget _buildCountryWidget({
    required String country,
    required String city,
    required String timeZone,
  }) {
    final now = tz.TZDateTime.now(tz.getLocation(timeZone));
    final formattedTime = DateFormat('HH:mm').format(now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 3,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  country,
                  style: textStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorSys.darkBlue,
                  ),
                ),
                Text(
                  city,
                  style: textStyle(fontSize: 18, color: ColorSys.darkBlue),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                formattedTime,
                style: textStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ColorSys.darkBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
