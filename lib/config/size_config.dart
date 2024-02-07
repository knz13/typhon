import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? defaultSize;
  static Orientation? orientation;
  static late double normalSpacing;
  static late double largeSpacing;
  static late double figmaScreenWidth;
  static late double figmaScreenHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    normalSpacing = getProportionateScreenHeight(10);
    largeSpacing = getProportionateScreenHeight(20);
      figmaScreenHeight = 1025.0;
      figmaScreenWidth = 1440.0;
  }
}

double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
    return (inputHeight / 1025.0) * screenHeight;
}

double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
    return (inputWidth / 1440.0) * screenWidth;
}

double getProportionateFontSize(double figmaFontSize) {
  return (figmaFontSize / SizeConfig.figmaScreenHeight) * SizeConfig.screenHeight;
}
