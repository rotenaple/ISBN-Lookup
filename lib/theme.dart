import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:isbnsearch_flutter/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AppTheme {
  static bool get darkMode => SharedPrefs().isDarkModeEnabled;

  static Color primaryColourLight = Color(0xFF002EA9);
  static Color primaryColourDark = Color(0xFFA97C00);
  static Color get primaryColour {
    return darkMode ? primaryColourDark : primaryColourLight;
  }

  static Color altPrimColourLight = Color(0xFF7182DB);
  static Color altPrimColourDark = Color(0xFFFFF197);
  static Color get altPrimColour {
    return darkMode ? altPrimColourDark : AppTheme.altPrimColourLight;
  }

  static Color get sysStatusBarColour {
    return darkMode ? backgroundColourDark : primaryColourLight;
  }
  static Color get sysNavBarColour {
    return darkMode ? backgroundColourDark : altPrimColourLight;
  }

  static Color get navIndicatorColour {
    return darkMode ? primaryColourDark : altPrimColourLight;
  }

  static Color backgroundColourLight = Color(0xFFFFFFFF);
  static Color backgroundColourDark = Color(0xFF000000);
  static Color get backgroundColour {
    return darkMode ? backgroundColourDark : backgroundColourLight;
  }

  static Color altBackgroundColourLight = Color(0xFFE7E9F9);
  static Color altBackgroundColuorDark = Color(0xFF282A36);
  static Color get altBackgroundColour {
    return darkMode ? altBackgroundColuorDark : altBackgroundColourLight;
  }

  static Color textColourLight = Color(0xFF171717);
  static Color textColourDark = Color(0xFFF8F8F2);
  static Color get textColour {
    return darkMode ? textColourDark : textColourLight;
  }

  static Color unselectedColourLight = Color(0xFFD8D8D8);
  static Color unselectedColourDark = Color(0xFF666666);
  static Color get unselectedColour {
    return darkMode ? unselectedColourDark : unselectedColourLight;
}

  static Color warningColour = Color(0xFFF44336);


  static TextStyle get h1 => TextStyle(
    fontWeight: darkMode ? FontWeight.w600 : FontWeight.w700,
    fontSize: 24,
    height: 0.9,
    color: textColour,
  );

  static TextStyle get h2 => TextStyle(
    fontWeight: darkMode ? FontWeight.w500 : FontWeight.w600,
    fontSize: 16,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static TextStyle get h3 => TextStyle(
    fontWeight: darkMode ? FontWeight.w600 : FontWeight.w700,
    color: textColour,
    fontSize: 14,
    fontFamily: 'Barlow',
  );

  static TextStyle get normalTextStyle => TextStyle(
    fontWeight: darkMode ? FontWeight.w400 : FontWeight.w500,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static TextStyle get condTextStyle => TextStyle(
      // Only used for large text block in book description to save space
    fontWeight: darkMode ? FontWeight.w400 : FontWeight.w500,
      height: 1,
      color: textColour,
      fontFamily: 'BarlowSemiCond',
  );

  static TextStyle get warningTextStyle => TextStyle(
    fontWeight: darkMode ? FontWeight.w400 : FontWeight.w500,
    color: warningColour,
    fontFamily: 'Barlow',
  );

  static TextStyle get boldTextStyle => TextStyle(
    fontWeight: darkMode ? FontWeight.w500 : FontWeight.w600,
    height: 1.2,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static TextStyle get buttonTextStyle => TextStyle(
    fontWeight: FontWeight.w500,
    fontFamily: 'Barlow',
  );

  static TextStyle get dialogContentStyle => TextStyle(
    fontWeight: darkMode ? FontWeight.w400 : FontWeight.w500,
    fontSize: 16,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static TextStyle get dialogButtonStyle => TextStyle(
    fontWeight: darkMode ? FontWeight.w500 : FontWeight.w600,
    fontSize: 16,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static TextStyle get dialogAlertButtonStyle => TextStyle(
    fontWeight: darkMode ? FontWeight.w500 : FontWeight.w600,
    fontSize: 16,
    color: warningColour,
    fontFamily: 'Barlow',
  );

  static SnackBar customSnackbar(String message) {
    return SnackBar(
      content: Text(
        message,
        style: AppTheme.normalTextStyle,
      ),
      backgroundColor: AppTheme.unselectedColour,
      duration: const Duration(seconds: 2),
    );
  }

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    foregroundColor: altBackgroundColourLight,
    backgroundColor: primaryColour,
    textStyle: buttonTextStyle,
  );
}

class SearchIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final String link;

  const SearchIconButton({
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
            Icon(icon, color: AppTheme.altBackgroundColourLight,),
            Text(text, style: AppTheme.buttonTextStyle),
          ],
        ),
      ),
    );
  }
}

class ResultTextBlock extends StatelessWidget {
  final String title;
  final String content;

  const ResultTextBlock({
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

class CustomCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final Widget? trailingWidget;

  const CustomCard({
    Key? key,
    required this.onTap,
    required this.title,
    this.trailingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.altBackgroundColour,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          title: Text(
            title,
            style: AppTheme.normalTextStyle,
          ),
          trailing: trailingWidget,
        ),
      ),
    );
  }
}

class CustomSettingCard extends CustomCard {
  final Color? textColor;

  CustomSettingCard({
    Key? key,
    required VoidCallback onTap,
    required String title,
    this.textColor, // Optional parameter
  }) : super(key: key, onTap: onTap, title: title);

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = AppTheme.normalTextStyle.copyWith(
      color: textColor ?? AppTheme.normalTextStyle.color, // Use provided textColor or default
    );

    return Card(
      color: AppTheme.altBackgroundColour,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          title: Text(
            title,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

class CustomSettingSwitchCard extends CustomSettingCard {
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;
  final Color? activeSwitchColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;

  CustomSettingSwitchCard({
    Key? key,
    required VoidCallback onTap,
    required String title,
    required this.switchValue,
    required this.onSwitchChanged,
    this.activeSwitchColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
  }) : super(key: key, onTap: onTap, title: title);

  @override
  Widget build(BuildContext context) {
    Color finalActiveSwitchColor = activeSwitchColor ?? AppTheme.primaryColour;
    Color finalActiveTrackColor = activeTrackColor ?? AppTheme.altPrimColour;
    Color finalInactiveThumbColor = inactiveThumbColor ?? AppTheme.backgroundColour;
    Color finalInactiveTrackColor = inactiveTrackColor ?? AppTheme.unselectedColour;

    return CustomCard(
      onTap: onTap,
      title: title,
      trailingWidget: Switch(
        value: switchValue,
        onChanged: onSwitchChanged,
        activeColor: finalActiveSwitchColor,
        activeTrackColor: finalActiveTrackColor,
        inactiveThumbColor: finalInactiveThumbColor,
        inactiveTrackColor: finalInactiveTrackColor,
      ),
    );
  }
}
