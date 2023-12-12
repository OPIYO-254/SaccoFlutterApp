import 'package:flutter/material.dart';
import 'package:sojrel_sacco_client/utils/colors.dart';

class MyTextFormField extends StatelessWidget {
  const MyTextFormField({
    super.key,
    required this.fieldController,
    required this.validatorText,
    required this.hintText,
    required this.obscureText,
    required this.iconColor,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType

  });

  final TextEditingController fieldController;
  final String validatorText;
  final String hintText;
  final bool obscureText;
  final Color iconColor;
  final Icon prefixIcon;
  final GestureDetector? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    MyColors colors = MyColors();
    return Container(
      // height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12,),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,
          // border: Border.all(color: colors.lightGrey),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),)
      ),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorText;
          }
          return null;
        },
        cursorColor: Theme.of(context).colorScheme.tertiary,
        keyboardType: keyboardType,
        obscureText:obscureText,
        controller: fieldController,
        decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            prefixIconColor: Theme.of(context).colorScheme.secondary,
            suffixIconColor: Theme.of(context).colorScheme.secondary,
            suffixIcon: suffixIcon,
            iconColor: iconColor,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            fillColor: colors.transparent,
            filled: true,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary,)
        ),
      ),
    );
  }
}


class NumericTextField extends StatelessWidget {

  const NumericTextField({
    super.key, required this.controller, required this.validator, required this.hintText,

  });
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    MyColors colors = MyColors();
    return TextFormField(
      validator: validator,
      controller: controller,
      // textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
        focusColor: colors.green,
        fillColor: Theme.of(context).colorScheme.primary,
        filled: true,
      ),
    );
  }
}