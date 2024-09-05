import 'package:flutter/material.dart';

// A fully custom TextField widget
class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final int maxLength;

  // Constructor with parameters to customize the TextField
  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.borderColor = Colors.blue,
    this.borderRadius = 10.0,
    this.textStyle,
    this.maxLength = 50,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      style: textStyle ?? const TextStyle(fontSize: 18, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: borderColor),
        filled: true,
        fillColor: Colors.grey[200], // Background color
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '', // Hide character count
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
    );
  }
}
