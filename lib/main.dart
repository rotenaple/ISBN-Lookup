import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'isbn_check.dart';
import 'scan_page.dart';
import 'search_result.dart';
import 'view_csv.dart';
import 'custom_keyboard.dart';
import 'desktop_keyboard.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Platform.isIOS || Platform.isAndroid
                      ? CustomKeyboardTextField(controller: isbnController)
                      : DesktopKeyboardTextField(controller: isbnController), // Use normal TextField on other platforms
                  FilledButton(
                    onPressed: () {
                      String isbn = isbnController.text;
                      search(context, isbn);
                    },
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            Expanded(
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
              FloatingActionButton(
                child: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewCSVPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),


    );
  }

}
