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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchResult(isbn: isbn)),
      );
    } else {
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
      drawer: DrawerWidget(),
      body: SafeArea(
        child: MainContent(
          isbnController: isbnController,
          search: search,
        ),
      ),
      floatingActionButton: FloatingActionButtons(),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.primaryColour,
            ),
            child: DrawerHeaderContent(),
          ),
          DrawerMenuItem(
            title: 'Lookup History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCSVPage(),
                ),
              );
              Scaffold.of(context).openEndDrawer();
            },
          ),
          DrawerMenuItem(
            title: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
              Scaffold.of(context).openEndDrawer();
            },
          ),
          DrawerMenuItem(
            title: 'About App',
            onTap: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}

class DrawerHeaderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class DrawerMenuItem extends StatelessWidget {
  final String title;
  final Function onTap;

  DrawerMenuItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        onTap();
      },
    );
  }
}

class MainContent extends StatelessWidget {
  final TextEditingController isbnController;
  final Function search;

  MainContent({required this.isbnController, required this.search});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: DrawerToggleIcon(),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InputInstructions(),
              Platform.isIOS || Platform.isAndroid
                  ? CustomKeyboardTextField(controller: isbnController)
                  : DesktopKeyboardTextField(controller: isbnController),
              SearchButton(
                onPressed: () {
                  String isbn = isbnController.text;
                  search(context, isbn);
                },
              ),
            ],
          ),
        ),
        const Expanded(
          flex: 1,
          child: Column(),
        ),
      ],
    );
  }
}

class DrawerToggleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Scaffold.of(context).openDrawer();
      },
      child: Icon(Icons.menu),
    );
  }
}

class InputInstructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Text(
        "Input an ISBN-10 or ISBN-13 number:",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.normal,
          color: Color(0xff000000),
        ),
      ),
    );
  }
}

class SearchButton extends StatelessWidget {
  final Function onPressed;

  SearchButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        onPressed();
      },
      child: const Text('Search'),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(AppTheme.primaryColour),
      ),
    );
  }
}

class FloatingActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 5, 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (Platform.isAndroid || Platform.isIOS)
              BarcodeScannerButton(),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class BarcodeScannerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
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
    );
  }
}
