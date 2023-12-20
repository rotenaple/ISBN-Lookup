import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:isbnsearch_flutter/theme.dart';

class CustomKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CustomKeyboard({Key? key, required this.onKeyPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildKeyboardRow(['1', '2', '3']),
            buildKeyboardRow(['4', '5', '6']),
            buildKeyboardRow(['7', '8', '9']),
            buildKeyboardRow(['X', '0', buildBackspaceButton()]),
          ],
        ),
      ),
    );
  }


  Widget buildKeyboardRow(List<dynamic> keys) {
    return Row(
      children: keys.map((key) {
        if (key is String) {
          return buildDigitButton(key);
        } else if (key is Widget) {
          return key;
        } else {
          throw ArgumentError('Invalid key type');
        }
      }).toList(),
    );
  }

  Widget buildDigitButton(String digit) {
    return Expanded(
      child: TextButton(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 24.0,
              color: AppTheme.primaryColour, // Set the desired text color
            ),
          ),
        onPressed: () {
          if (_isValidInput(digit)) {
            onKeyPressed(digit);
            _vibrateOnKeyPress();
          }
        },
      ),
    );
  }

  Widget buildBackspaceButton() {
    return Expanded(
      child: GestureDetector(
        onLongPress: () {
          onKeyPressed('clear'); // Use 'clear' as the key identifier for the long-press on backspace
          _vibrateOnKeyPress();
        },
        child: TextButton(
          child: const Icon(
            Icons.backspace,
            size: 24.0,
            color: AppTheme.primaryColour,
          ),
          onPressed: () {
            onKeyPressed('backspace');
            _vibrateOnKeyPress();
          },
        ),
      ),
    );
  }

  Future<void> _vibrateOnKeyPress() async {
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.medium); // Vibrate with light feedback
    }
  }

  bool _isValidInput(String digit) {
    // Only allow digits from 0 to 9 and the letter X
    return RegExp(r'^[\dX]$').hasMatch(digit);
  }
}

class CustomKeyboardTextField extends StatefulWidget {
  final TextEditingController controller;

  const CustomKeyboardTextField({Key? key, required this.controller}) : super(key: key);

  @override
  _CustomKeyboardTextFieldState createState() => _CustomKeyboardTextFieldState();
}

class _CustomKeyboardTextFieldState extends State<CustomKeyboardTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        floatingLabelAlignment: FloatingLabelAlignment.center,
      ),
      textAlign: TextAlign.center,
      maxLength: 13,
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\dXx]')),
      ],
      autocorrect: false,
      enableInteractiveSelection: false,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _showCustomKeyboard(context);
      },
    );
  }

  void _showCustomKeyboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            canvasColor: Colors
                .transparent, // Set the background color to transparent
          ),
          child: Container(
            color: Colors.white,
            // Set the background color of the container to match the keyboard color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: IntrinsicHeight(
                child: CustomKeyboard(

                  onKeyPressed: (key) {
                    setState(() {
                      if (key == 'backspace') {
                        if (widget.controller.text.isNotEmpty) {
                          widget.controller.text =
                              widget.controller.text.substring(
                                  0, widget.controller.text.length - 1);
                        }
                      } else if (key == 'clear') {
                        widget.controller.clear(); // Clear all text
                      } else {
                        widget.controller.text += key;
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}