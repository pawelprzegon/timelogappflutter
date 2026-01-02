import 'dart:math';
import 'package:flutter/widgets.dart';

enum DeviceSize { phone, tablet, desktop }

class Responsive {
  static DeviceSize deviceSize(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 600) return DeviceSize.phone;
    if (w < 1024) return DeviceSize.tablet;
    return DeviceSize.desktop;
  }

  static double scale(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w/400).clamp(1.0, 1.6);
  }
  
  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return min(w, 1600);
  }
}
