import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppTheme {
  static const Color primaryColour = Color(0xFF002EA9);
  static const Color altPrimColour = Color(0xFF7F96D4);
  static const Color backgroundColour = Color(0xFFFFFFFF);
  static const Color altBackgroundColor = Color(0xFFF6EEE1);
  static const Color textColour = Color(0xFF000000);
  static const Color unselectedColour = Color(0xFFAAAAAA);
  static const Color warningColour = Color(0xFFF44336);

  static const Color iconColor = textColour;

  static const TextStyle listItemTextStyle = TextStyle(
    color: textColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle headerStyle = TextStyle(
    color: textColour,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: 'Barlow',
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    fontSize: 24,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle normalTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle bodyTextStyle = TextStyle(
    //Only used for large text block in book description to save space
    fontWeight: FontWeight.w500,
    height: 1,
    color: textColour,
    fontFamily: 'BarlowSemiCond',
  );

  static const TextStyle warningTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    color: warningColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle h1 = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 0.6,
    color: textColour,
  );

  static const TextStyle h2 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle h3 = TextStyle(
    fontWeight: FontWeight.w700,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle boldTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.2,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: backgroundColour,
    backgroundColor: primaryColour,
    textStyle: boldTextStyle,
  );

  static Widget styledContainer({required Widget child}) {
    return Card(
      color: altBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  static const TextStyle dialogTitleStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle dialogContentStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle dialogButtonStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle dialogAlertButtonStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: warningColour,
    fontFamily: 'Barlow',
  );

  static const TextStyle creditTextStyle = TextStyle(
    fontSize: 12,
    color: unselectedColour,
    fontFamily: 'Barlow',
  );

  static void showSnackbar(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 5)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.backgroundColour),
        ),
        duration: duration,
      ),
    );
  }
}

class TextGroupBlock extends StatelessWidget {
  final String title;
  final String content;

  const TextGroupBlock({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          overflow: TextOverflow.clip,
          style: AppTheme.h3,
        ),
        Text(
          content,
          overflow: TextOverflow.clip,
          style: AppTheme.normalTextStyle,
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final String link;

  const CustomButton({
    super.key,
    required this.text,
    required this.icon,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2.5, 5, 0),
      child: FilledButton(
        onPressed: () {
          launch(link);
        },
        style: AppTheme.primaryButtonStyle, // Use the predefined style,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            Text(text),
          ],
        ),
      ),
    );
  }
}
