import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isbn_book_search_test_flutter/theme.dart';


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
          borderSide: BorderSide(color: Colors.grey), // Set the desired color for the focused border
        ),

      ),
      textAlign: TextAlign.center,
      maxLength: 13,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      autocorrect: false,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
