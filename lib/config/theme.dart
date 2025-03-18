import 'package:flutter/material.dart';

import 'constants_color.dart';


ThemeData lightThemeDate(BuildContext context){
  return ThemeData.light(useMaterial3: true).copyWith(
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: backgroundColor,

    colorScheme: const ColorScheme.light(
        primary: kPrimaryColor,
        secondary:kSecondaryColor,
        error: KErrorColor
    ),
    appBarTheme: appBarTheme,
  );
}

ThemeData darkThemeDate(BuildContext context){
  return ThemeData.light(useMaterial3: true).copyWith(
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kDarkColor,

    colorScheme: const ColorScheme.light(
        primary: kPrimaryColor,
        secondary:kSecondaryColor,
        error: KErrorColor
    ),
    appBarTheme: appBarTheme.copyWith(
      backgroundColor: kDarkColor,
      iconTheme: IconThemeData(color: kWhiteColor),
    ),
  );
}

const appBarTheme = AppBarTheme(
  centerTitle: false,
  elevation: 0,
  backgroundColor: kWhiteColor,
  iconTheme: IconThemeData(color: kPrimaryColor),
  titleTextStyle: TextStyle(
      color: kDarkColor,
      fontSize: 25,
      fontWeight: FontWeight.bold
  ),

);