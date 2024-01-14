// ignore_for_file: prefer_const_constructors_in_immutables


import 'package:flutter/material.dart';
import 'package:isbnsearch_flutter/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AppTheme {
  static bool get darkMode => SharedPrefs().isDarkModeEnabled;

  static Color primaryColourLight = const Color(0xFF002EA9);
  static Color primaryColourDark = const Color(0xFFA97C00);
  static Color get primaryColour {
    return darkMode ? primaryColourDark : primaryColourLight;
  }

  static Color altPrimColourLight = const Color(0xFF7182DB);
  static Color altPrimColourDark = const Color(0xFFFFF197);
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

  static Color backgroundColourLight = const Color(0xFFFFFFFF);
  static Color backgroundColourDark = const Color(0xFF000000);
  static Color get backgroundColour {
    return darkMode ? backgroundColourDark : backgroundColourLight;
  }

  static Color altBackgroundColourLight = const Color(0xFFE7E9F9);
  static Color altBackgroundColuorDark = const Color(0xFF282A36);
  static Color get altBackgroundColour {
    return darkMode ? altBackgroundColuorDark : altBackgroundColourLight;
  }

  static Color textColourLight = const Color(0xFF171717);
  static Color textColourDark = const Color(0xFFF8F8F2);
  static Color get textColour {
    return darkMode ? textColourDark : textColourLight;
  }

  static Color unselectedTextColourLight = const Color(0xFF666666);
  static Color unselectedTextColourDark = const Color(0xFFA2A2A2);
  static Color get unselectedTextColour {
    return darkMode ? unselectedTextColourDark : unselectedTextColourLight;
  }

  static Color unselectedColourLight = const Color(0xFFD8D8D8);
  static Color unselectedColourDark = const Color(0xFF666666);
  static Color get unselectedColour {
    return darkMode ? unselectedColourDark : unselectedColourLight;
}

  static Color warningColourLight = const Color(0xFFE74C3C);
  static Color warningColourDark = const Color(0xFFC0392B);
  static Color get warningColour {
    return darkMode ? warningColourDark : warningColourLight;
  }


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

  static TextStyle get unselectedTextStyle => TextStyle(
    fontWeight: darkMode ? FontWeight.w400 : FontWeight.w500,
    color: unselectedTextColour,
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
    fontWeight: FontWeight.w500,
    color: warningColourLight,
    fontFamily: 'Barlow',
  );

  static TextStyle get boldTextStyle => TextStyle(
    fontWeight: darkMode ? FontWeight.w500 : FontWeight.w600,
    height: 1.2,
    color: textColour,
    fontFamily: 'Barlow',
  );

  static TextStyle get buttonTextStyle => const TextStyle(
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

  static ButtonStyle get filledButtonStyle => ElevatedButton.styleFrom(
    foregroundColor: altBackgroundColourLight,
    backgroundColor: primaryColour,
    textStyle: buttonTextStyle,
  );

  static ButtonStyle get filledWarningButtonStyle => ElevatedButton.styleFrom(
    foregroundColor: AppTheme.backgroundColourLight,
    backgroundColor: warningColourDark,
    textStyle: AppTheme.boldTextStyle,
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
      padding: const EdgeInsets.fromLTRB(5, 2.5, 5, 2.5),
      child: FilledButton(
        onPressed: () {
          launch(link);
        },
        style: AppTheme.filledButtonStyle, // Use the predefined style,
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
    super.key,
    required this.onTap,
    required this.title,
    this.trailingWidget,
  });

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
  final TextStyle? textStyle;

  CustomSettingCard({
    super.key,
    required super.onTap,
    required super.title,
    this.textStyle, // Optional parameter
  });

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
            style: textStyle ?? AppTheme.normalTextStyle,
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
    super.key,
    required super.onTap,
    required super.title,
    required this.switchValue,
    required this.onSwitchChanged,
    this.activeSwitchColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
  });

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
