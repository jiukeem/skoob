import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CustomTextInputFormatter extends TextInputFormatter {
  final RegExp regex;

  CustomTextInputFormatter({required String pattern}) : regex = RegExp(pattern);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;  // Allow clear input
    }

    // Check if the new character(s) match the allowed characters
    if (regex.hasMatch(newValue.text)) {
      return newValue;  // If yes, return the new value
    }
    // If not, return the old value (ignoring the new input)
    return oldValue;
  }
}