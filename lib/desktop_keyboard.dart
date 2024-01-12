// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isbnsearch_flutter/theme.dart';

class DesktopKeyboardTextField extends StatelessWidget {
  final TextEditingController controller;

  const DesktopKeyboardTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        floatingLabelAlignment: FloatingLabelAlignment.center,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.grey),
        ),
      ),
      textAlign: TextAlign.center,
      maxLength: 13,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      autocorrect: false,
      style: AppTheme.normalTextStyle,
    );
  }
}
