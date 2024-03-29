import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

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
