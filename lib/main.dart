import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:isbnsearch_flutter/settings_page.dart';
import 'isbn_check.dart';
import 'scan_page.dart';
import 'search_result.dart';
import 'view_csv.dart';
import 'custom_keyboard.dart';
import 'desktop_keyboard.dart';
import 'theme.dart';
import 'scan_page.dart';

void main() => runApp(MaterialApp(home: Home()));

class Home extends StatelessWidget {
  final TextEditingController isbnController = TextEditingController();

  Home({super.key});

  void search(BuildContext context, String isbn) {
    IsbnCheck checker = IsbnCheck();
    bool check = checker.isValidIsbnFormat(isbn);
    if (check) {
      // Use the isValidIsbn method from IsbnUtils class
      // Navigate to the result page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchResult(isbn: isbn)),
      );
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 500),
          content: Text('Invalid ISBN'),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey, // Assign the scaffoldKey to the Scaffold
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.primaryColour,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ISBN Lookup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'version 1.0.0\nby rotenaple',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            ),
            ListTile(
              title: const Text('Lookup History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewCSVPage(),
                  ),
                );
                scaffoldKey.currentState?.closeDrawer();
              },
            ),
            ListTile(
              title: const Text('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                    ),
                  );
                  scaffoldKey.currentState?.closeDrawer();
                }
            ),
            ListTile(
              title: const Text('About App'),
              onTap: () {
                // Handle the about app menu item tap event
                scaffoldKey.currentState?.closeDrawer();
                // Perform the desired action here
              },
            ),
          ],
        ),
      ), //Drawer
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
                  children: [
                    GestureDetector(
                      onTap: () {
                        scaffoldKey.currentState?.openDrawer();
                        // Open the sliding menu (drawer)
                      },
                      child: Icon(Icons.menu),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),

                    child: Text(
                      "Input an ISBN-10 or ISBN-13 number:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        //fontSize: 16,
                        color: Color(0xff000000),
                      ),
                    ),),
                  Platform.isIOS || Platform.isAndroid
                      ? CustomKeyboardTextField(controller: isbnController)
                      : DesktopKeyboardTextField(controller: isbnController), // Use normal TextField on other platforms
                  FilledButton(
                    onPressed: () {

                      String isbn = isbnController.text;
                      search(context, isbn);
                    },
                    child: const Text('Search'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColour), // Set the background color of the button to blue
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 1,
              child: Column(),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (Platform.isAndroid || Platform.isIOS) // Conditionally show the barcode button on Android and iOS
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScanPage()),
                    );
                  },
                  backgroundColor: AppTheme.primaryColour,
                  child: SvgPicture.asset(
                    'images/barcode_scanner.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: 24,
                    height: 24,
                  ),
                ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

}
