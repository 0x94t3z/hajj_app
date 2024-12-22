import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

class ThirdWidget extends StatefulWidget {
  const ThirdWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ThirdWidgetState createState() => _ThirdWidgetState();
}

class _ThirdWidgetState extends State<ThirdWidget> {
  final List<Widget> images = [
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        "https://i.pinimg.com/564x/d8/b5/fc/d8b5fc77289f06cd442f8e99d9adeda0.jpg",
        fit: BoxFit.cover,
      ),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        "https://i.pinimg.com/564x/21/1f/9d/211f9dc93146ff9c89849410da153d0e.jpg",
        fit: BoxFit.cover,
      ),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        "https://i.pinimg.com/564x/c6/3f/72/c63f724ff95d6d869cac725215559fff.jpg",
        fit: BoxFit.cover,
      ),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        "https://i.pinimg.com/736x/67/b9/e8/67b9e836f723232a38571a95b8cd4b2f.jpg",
        fit: BoxFit.cover,
      ),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        "https://i.pinimg.com/564x/3f/ee/68/3fee683848bb4d9a607a5c91da0d2fd3.jpg",
        fit: BoxFit.cover,
      ),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        "https://i.pinimg.com/736x/52/ff/e3/52ffe34735758a0a85834c36e77dfdbc.jpg",
        fit: BoxFit.cover,
      ),
    ),
  ];
  final List<String> titles = [
    'Saepudin',
    'Rifqotul Aulia',
    'Abdullah',
    '',
    '',
    ''
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: VerticalCardPager(
                  images: images.map((image) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // White background
                        borderRadius:
                            BorderRadius.circular(25.0), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.grey.withOpacity(0.2), // Softer shadow
                            spreadRadius: 3, // Spread radius of shadow
                            blurRadius: 3, // Blur radius of shadow
                            offset: const Offset(0, 3), // Shadow position
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            25.0), // Match the borderRadius
                        child: image,
                      ),
                    );
                  }).toList(),
                  titles: titles,
                  textStyle: textStyle(
                      color: ColorSys.grey, fontWeight: FontWeight.bold),
                  onPageChanged: (page) {},
                  onSelectedItem: (index) {
                    print(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
