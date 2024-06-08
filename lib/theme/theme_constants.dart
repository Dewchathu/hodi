import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,

  brightness: Brightness.light,
  primarySwatch: Colors.orange,
  shadowColor: Colors.black,
  primaryColor: const Color(0xFFC6293C),
  focusColor: Colors.black,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionColor: Colors.black.withOpacity(0.5),
    selectionHandleColor: Colors.black,
  ),

);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primarySwatch: Colors.orange,
  shadowColor: Colors.white,
  primaryColor: const Color(0xFFC6293C),
  focusColor:Colors.white,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.white,
    selectionColor: Colors.white.withOpacity(0.5),
    selectionHandleColor: Colors.white,
  ),
);