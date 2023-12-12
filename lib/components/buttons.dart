import 'package:flutter/material.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

class MyRaisedButton extends StatelessWidget {
  const MyRaisedButton({super.key, required this.text, required this.onTap,});
  final String text;
  final Function () onTap;
  @override
  Widget build(BuildContext context) {
    MyColors colors = MyColors();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: MediaQuery.sizeOf(context).width,
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
        decoration: BoxDecoration(
          color: colors.green,
          borderRadius: BorderRadius.circular(10),
        ),

      ),
    );
  }
}

class FlatTextButton extends StatelessWidget {
  const FlatTextButton({super.key, required this.onPressed, required this.text});
  final Function() onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    MyColors colors = MyColors();
    return TextButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: colors.green))
    );
  }
}

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.color, required this.onTap, required this.text, required this.width, required this.height, required this.borderRadius,
  });
  final Function() onTap;
  final Color color;
  final String text;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      ),
    );
  }
}
