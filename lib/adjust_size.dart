import 'package:flutter/material.dart';

class IconSize {
  static double smallIconSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.06; // 5% of screen width
  }

  // Function to calculate the medium icon size based on screen width
  static double mediumIconSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.07; // 7% of screen width
  }

  // Function to calculate the large icon size based on screen width
  static double largeIconSize(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.08; // 10% of screen width
  }

  static double BottomIcon(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.08; // 10% of screen width
  }
}

class Sizes {
  static double heights(BuildContext context){
    return MediaQuery.of(context).size.height;
  }
  static double widths(BuildContext context){
    return MediaQuery.of(context).size.width;
  }
}
