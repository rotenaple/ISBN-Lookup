import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:isbn_book_search_test_flutter/isbn_check.dart';
import 'package:isbn_book_search_test_flutter/scan_page.dart';
import 'package:isbn_book_search_test_flutter/search_result.dart';
import 'package:isbn_book_search_test_flutter/view_csv.dart';
import 'custom_keyboard.dart';

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
                  CustomKeyboardTextField(controller: isbnController),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ScanPage()),
                      );
                    },
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'images/barcode_scanner.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  FloatingActionButton(
                    child: const Icon(Icons.history), // Use the history icon
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewCSVPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
          ],
        ),
      ),
    ]
    ),
    ),);
  }
}
