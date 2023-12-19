import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isbn_book_search_test_flutter/theme.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences sharedPreferences;
  bool isDarkModeEnabled = false;
  bool isImgLookupDisabled = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                    child: const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    toggleDarkMode(!isDarkModeEnabled);
                  },
                  child: Card(
                    child: ListTile(
                      title: const Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      trailing: Switch(
                        value: isDarkModeEnabled,
                        activeColor: AppTheme.primaryColour,
                        activeTrackColor: AppTheme.altPrimColour,
                        inactiveThumbColor: AppTheme.backgroundColour,
                        inactiveTrackColor: AppTheme.unselectedColour,
                        onChanged: toggleDarkMode,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    toggleImgLookup(!isImgLookupDisabled);
                  },
                  child: Card(
                    child: ListTile(
                      title: const Text(
                        'Disable Image Search',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      trailing: Switch(
                        value: isImgLookupDisabled,
                        activeColor: AppTheme.primaryColour,
                        activeTrackColor: AppTheme.altPrimColour,
                        inactiveThumbColor: AppTheme.backgroundColour,
                        inactiveTrackColor: AppTheme.unselectedColour,
                        onChanged: toggleImgLookup,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Card(
                    child: ListTile(
                      title: Text(
                        'Set Custom Search Button',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _exportFile();
                  },
                  child: const Card(
                    child: ListTile(
                      title: Text(
                        'Export Lookup Records',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: const Text(
                              'Are you sure you want to delete all records?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(
                                    false); // Return false to indicate cancellation
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: AppTheme
                                      .warningColour, // Set the text color to red
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(
                                    true); // Return true to indicate confirmation
                              },
                            )
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
                  child: const Card(
                    child: ListTile(
                      title: Text(
                        'Delete Lookup Records',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.warningColour,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: AppTheme.primaryColour,
                child: const Icon(Icons.arrow_back),
              ),
            ],
          ),
        ),
      ),
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
      if (await Permission.storage
          .request()
          .isGranted) {
        final downloadsDirectory = await getExternalStorageDirectory();
        final newFilePath = '${downloadsDirectory?.path}/output.csv';
        await file.copy(newFilePath);
        print('File exported successfully.');

        _showSnackBar('File exported successfully');
      } else {
        print('Permission to access storage denied.');
        _showSnackBar('Permission to access storage denied');
      }
    } catch (e) {
      print('Error exporting file: $e');
      _showSnackBar('Error exporting file: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

}