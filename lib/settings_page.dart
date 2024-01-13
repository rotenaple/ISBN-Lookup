import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isbnsearch_flutter/theme.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  bool get isDarkModeEnabled => _sharedPrefs?.getBool('isDarkModeEnabled') ?? false;
  set isDarkModeEnabled(bool value) => _sharedPrefs?.setBool('isDarkModeEnabled', value);

  bool get isImgLookupDisabled => _sharedPrefs?.getBool('isImgLookupDisabled') ?? false;
  set isImgLookupDisabled(bool value) => _sharedPrefs?.setBool('isImgLookupDisabled', value);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key});


  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences sharedPreferences;
  bool isDarkModeEnabled = false;
  bool isImgLookupDisabled = false;

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isDarkModeEnabled =
          sharedPreferences.getBool('isDarkModeEnabled') ?? false;
      isImgLookupDisabled =
          sharedPreferences.getBool('isImgLookupDisabled') ?? false;
    });
  }

  void toggleDarkMode(bool value) {
    setState(() {
      isDarkModeEnabled = value;
      sharedPreferences.setBool('isDarkModeEnabled', value);
      if (kDebugMode) {
        print(value);
      }
    });
  }

  void toggleImgLookup(bool value) {
    setState(() {
      isImgLookupDisabled = value;
      sharedPreferences.setBool('isImgLookupDisabled', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColour,
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Text(
                      'Settings',
                      style: AppTheme.h1,
                    ),
                  ),
                ),
                CustomSettingSwitchCard(
                  onTap: () {
                    toggleDarkMode(!isDarkModeEnabled);
                  },
                  title: 'Dark Mode',
                  switchValue: isDarkModeEnabled,
                  onSwitchChanged: toggleDarkMode,
                ),
                CustomSettingSwitchCard(
                  onTap: () {
                    toggleImgLookup(!isImgLookupDisabled);
                  },
                  title: 'Disable Image Search',
                  switchValue: isImgLookupDisabled,
                  onSwitchChanged: toggleImgLookup,
                ),
                CustomSettingCard(
                  onTap: () {
                    // Define action for 'Set Custom Search Button'
                  },
                  title: 'Set Custom Search Button',
                ),
                CustomSettingCard(
                  onTap: () {
                    _exportFile();
                  },
                  title: 'Export Lookup Records',
                ),
                CustomSettingCard(
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: AppTheme.altBackgroundColour,
                          title: Text(
                              "Delete All Records",
                          style: AppTheme.boldTextStyle,),
                          content: Text(
                            'Are you sure you want to delete all records?',
                            style: AppTheme.dialogContentStyle, // Apply dialog content style here
                          ),
                          actions: [
                            TextButton(
                              child: Text('Cancel', style: AppTheme.dialogButtonStyle), // Apply dialog button style
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: Text('Delete', style: AppTheme.dialogAlertButtonStyle), // Apply dialog alert button style
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      final directory = await getApplicationDocumentsDirectory();
                      final filePath = '${directory.path}/output.csv';
                      final file = File(filePath);
                      final exists = await file.exists();

                      if (exists) {
                        await file.delete();
                      }
                    }
                  },
                  title: 'Delete Lookup Records',
                  textColor: AppTheme.warningColour,
                ),
              ],
            ),
          )),
    );
  }


  Future<void> _exportFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/output.csv';
    final file = File(filePath);
    final exists = await file.exists();

    print(filePath);

    if (!exists) {
      print('File does not exist at the given path.');
      return;
    }

    try {
      if (await Permission.storage.request().isGranted) {
        final downloadsDirectory = await getExternalStorageDirectory();
        final newFilePath = '${downloadsDirectory?.path}/output.csv';
        await file.copy(newFilePath);
        print('File exported successfully.');

        ScaffoldMessenger.of(context).showSnackBar(AppTheme.customSnackbar('File exported successfully'));
      } else {
        print('Permission to access storage denied.');
        ScaffoldMessenger.of(context).showSnackBar(AppTheme.customSnackbar('Permission to access storage denied'));
      }
    } catch (e) {
      print('Error exporting file: $e');
      AppTheme.customSnackbar('Error exporting file: $e');
    }
  }
}
