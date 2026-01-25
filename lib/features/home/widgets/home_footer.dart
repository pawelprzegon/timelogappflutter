import 'package:flutter/material.dart';
import 'package:timelogappflutter/features/device/ui/device_widget.dart';

import '../../weather/ui/weather_widget.dart';

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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
            child: WeatherCard()
        ),
        // const Spacer(),
        Expanded(
            child: DeviceCard(),
        ),
      ],
    );
  }
}

