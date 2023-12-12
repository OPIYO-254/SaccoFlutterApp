import 'package:flutter/material.dart';
class MyDivider extends StatelessWidget {
  MyDivider({
    super.key,
  });

  @override
  Widget build(context) {
    return Divider(
      height: 1.0,
      color: Theme.of(context).colorScheme.tertiary,
    );
  }
}