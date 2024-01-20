import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  String get customSearchName => _sharedPrefs?.getString('customSearchName') ?? "Findit@Flinders";
  set customSearchName(String value) => _sharedPrefs?.setString('customSearchName', value);

  String get customSearchDomain => _sharedPrefs?.getString('customSearchDomain') ?? "https://flinders.primo.exlibrisgroup.com/discovery/search?query=any,contains,[isbn]&vid=61FUL_INST:FUL&tab=Everything&facet=rtype,exclude,reviews";
  set customSearchDomain(String value) => _sharedPrefs?.setString('customSearchDomain', value);


  bool get isDarkModeEnabled =>
      _sharedPrefs?.getBool('isDarkModeEnabled') ?? false;
  set isDarkModeEnabled(bool value) =>
      _sharedPrefs?.setBool('isDarkModeEnabled', value);

  bool get isImgLookupDisabled =>
      _sharedPrefs?.getBool('isImgLookupDisabled') ?? false;
  set isImgLookupDisabled(bool value) =>
      _sharedPrefs?.setBool('isImgLookupDisabled', value);
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
  String customSearchDomain = "";
  String customSearchName = "";

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isDarkModeEnabled = sharedPreferences.getBool('isDarkModeEnabled') ?? false;
      isImgLookupDisabled = sharedPreferences.getBool('isImgLookupDisabled') ?? false;
      customSearchName = sharedPreferences.getString('customSearchName') ?? "Findit@Flinders";
      customSearchDomain = sharedPreferences.getString('customSearchDomain') ??
          "https://flinders.primo.exlibrisgroup.com/discovery/search?query=any,contains,[isbn]&vid=61FUL_INST:FUL&tab=Everything&facet=rtype,exclude,reviews";
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final TextEditingController siteNameController = TextEditingController(text: customSearchName);
                    final TextEditingController siteLinkController = TextEditingController(text: customSearchDomain);

                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        bool areFieldsNotEmpty = siteNameController.text.isNotEmpty && siteLinkController.text.isNotEmpty;

                        return Align(
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            child: AlertDialog(
                              backgroundColor: AppTheme.altBackgroundColour,
                              title: Text('Custom Search Settings', style: AppTheme.boldTextStyle),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TextField(
                                    controller: siteNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Site Name',
                                      labelStyle: AppTheme.normalTextStyle,
                                    ),
                                    onChanged: (value) {
                                      setState(() => areFieldsNotEmpty = value.isNotEmpty && siteLinkController.text.isNotEmpty);
                                    },
                                    maxLines: null,
                                    style: AppTheme.normalTextStyle,
                                  ),
                                  TextField(
                                    controller: siteLinkController,
                                    decoration: InputDecoration(
                                        labelText: 'Site Link',
                                        labelStyle: AppTheme.normalTextStyle),
                                    onChanged: (value) {
                                      setState(() => areFieldsNotEmpty = value.isNotEmpty && siteNameController.text.isNotEmpty);
                                    },
                                    maxLines: null,
                                    style: AppTheme.normalTextStyle,
                                  ),
                                  Padding(padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Use [isbn] as a placeholder in site link.\n'
                                            'e.g. Use https://www.google.com/search?q=[isbn] to search on Google.',
                                        style: AppTheme.unselectedTextStyle,
                                      ))

                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel', style: AppTheme.dialogButtonStyle),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  style: AppTheme.filledButtonStyle,
                                  onPressed: areFieldsNotEmpty ? () async {
                                    String siteName = siteNameController.text;
                                    String siteLink = siteLinkController.text;
                                    sharedPreferences.setString('customSearchName', siteName);
                                    sharedPreferences.setString('customSearchDomain', siteLink);
                                    setState(() {
                                      customSearchName = siteName;
                                      customSearchDomain = siteLink;
                                    });
                                    Navigator.of(context).pop();
                                  } : null,
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              title: 'Set Custom Search Button',
            ),
            CustomSettingCard(
              onTap: () {
                _exportFile();
              },
              title: 'Export Lookup History',
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
                        style: AppTheme.boldTextStyle,
                      ),
                      content: Text(
                        'Are you sure you want to delete all records?',
                        style: AppTheme.dialogContentStyle,
                      ),
                      actions: [
                        TextButton(
                          child:
                              Text('Cancel', style: AppTheme.dialogButtonStyle),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        ElevatedButton(
                          style: AppTheme.filledWarningButtonStyle,
                          child: const Text('Delete'),
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
              title: 'Delete Lookup History',
              textStyle: AppTheme.warningTextStyle,
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

        ScaffoldMessenger.of(context).showSnackBar(
            AppTheme.customSnackbar('File exported successfully'));
      } else {
        print('Permission to access storage denied.');
        ScaffoldMessenger.of(context).showSnackBar(
            AppTheme.customSnackbar('Permission to access storage denied'));
      }
    } catch (e) {
      print('Error exporting file: $e');
      AppTheme.customSnackbar('Error exporting file: $e');
    }
  }
}
