import 'package:flutter/material.dart';

import '../utils/colors.dart';

MyColors colors = MyColors();

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey[100]!,
    primary:Colors.white,
    secondary: Colors.grey[500]!,
    tertiary: Colors.grey[900]!,
  )
);