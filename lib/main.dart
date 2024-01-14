import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isbnsearch_flutter/settings_page.dart';
import 'isbn_check.dart';
import 'barcode_search.dart';
import 'search_result.dart';
import 'lookup_history.dart';
import 'custom_keyboard.dart';
import 'desktop_keyboard.dart';
import 'theme.dart';

void main() => runApp(const MaterialApp(home: Home()));

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool darkMode = false;

  void updateUIFromPrefs() {
    darkMode = SharedPrefs().isDarkModeEnabled;
  }

  @override
  void initState() {
    SharedPrefs().init();
    super.initState();
    updateUIFromPrefs();
  }

  static final List<Widget> _widgetOptions = <Widget>[
    TextboxSearch(),
    if (Platform.isAndroid) const BarcodeSearch(),
    const LookupHistoryPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppTheme.sysStatusBarColour,
      systemNavigationBarColor: AppTheme.sysNavBarColour,
    ));
    return Scaffold(
      backgroundColor: AppTheme.backgroundColour,
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const BottomNavBar(
      {super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {

    List<NavigationDestination> destinations = [
      NavigationDestination(icon: Icon(Icons.keyboard, color: AppTheme.textColour),label: 'Search'),
      if (Platform.isAndroid)
        NavigationDestination(
          icon: Icon(Icons.camera, color: AppTheme.textColour),
          label: 'Scan Barcode',
        ),
      NavigationDestination(
        icon: Icon(Icons.history, color: AppTheme.textColour),
        label: 'History',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings, color: AppTheme.textColour),
        label: 'Settings',
      ),
    ];

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.all(AppTheme.normalTextStyle),
        backgroundColor: AppTheme.altBackgroundColour,
        indicatorColor: AppTheme.navIndicatorColour,
      ),
      child: NavigationBar(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onItemTapped,
        destinations: destinations,
      ),
    );
  }
}

class TextboxSearch extends StatelessWidget {
  final TextEditingController isbnController = TextEditingController();

  TextboxSearch({super.key});

  void search(BuildContext context, String isbn) {
    IsbnCheck checker = IsbnCheck();
    bool check = checker.isValidIsbnFormat(isbn);
    if (check) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchResult(isbn: isbn)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppTheme.customSnackbar('Invalid ISBN'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(30),
              // child: DrawerToggleIcon(),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const InputInstructions(),
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

class InputInstructions extends StatelessWidget {
  const InputInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Text(
        "Input an ISBN Number",
        textAlign: TextAlign.center,
        style: AppTheme.h2,
      ),
    );
  }
}

class SearchButton extends StatelessWidget {
  final Function onPressed;

  const SearchButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        onPressed();
      },
      style: AppTheme.filledButtonStyle,
      child: const Text('Search'),
    );
  }
}
