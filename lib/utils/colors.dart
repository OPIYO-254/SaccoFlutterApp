import 'package:flutter/material.dart';

class MyColors {
  Color darkGreen = const Color.fromRGBO(9, 160, 142, 1.0);
  Color green = const Color.fromRGBO(21, 192, 120, 1.0);
  Color brightGreen = const Color.fromRGBO(12, 222, 146, 1.0);
  Color lightGreen = const Color.fromRGBO(9, 170, 92, .3);
  Color transparent = const Color.fromRGBO(0, 0, 0, 0);
  Color white = const Color.fromRGBO(255, 255, 255, 1.0);
  Color deepOrange = const Color.fromRGBO(255, 87, 34, 1.0);
  Color black = const Color.fromRGBO(100,100,100,1);



  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return green;
    }
    return green;
  }
}


