import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  shadowColor: Colors.black,
  primaryColor: const Color(0xFFC6293C),
  focusColor: Colors.black,
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  shadowColor: Colors.white,
  primaryColor: const Color(0xFFC6293C),
  focusColor:Colors.white,
);