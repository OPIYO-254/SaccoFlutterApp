import 'package:flutter/material.dart';

import '../utils/colors.dart';

MyColors colors = MyColors();
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        background: Colors.grey[800]!,
        primary:Colors.grey[700]!,
        secondary: Colors.grey[500]!,
        tertiary: Colors.grey[300]!,
    )
);