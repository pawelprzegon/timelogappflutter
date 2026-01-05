import 'package:flutter/material.dart';
import 'package:timelogappflutter/features/device/ui/device_widget.dart';

import '../../../weather/ui/weather_widget.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({
    super.key,
    required this.weatherText,
    required this.deviceText,
  });

  final String weatherText;
  final String deviceText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: WeatherCard()),  // lewa strona zajmuje resztę
        const Spacer(),                  // wypycha na prawo
        DeviceCard(),                    // mały, przy prawej
      ],
    );
  }
}

