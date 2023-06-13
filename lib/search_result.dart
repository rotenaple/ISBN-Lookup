import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml2json/xml2json.dart';

import 'isbn_check.dart';

class SearchResult extends StatefulWidget {
  final String isbn;

  const SearchResult({super.key, required this.isbn});

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  String _title = '';
  String _authors = '';
  String _isbn = '';
  String _publisher = '';
  String _publicationYear = '';
  String _description = '';
  String _coverlink = '';
  String _ddc = '';
  String _bookNew = '', _bookUsed = '', _destination = '';

  @override
  void initState() {
    super.initState();
    search(widget.isbn);
  }

  bool _isSearchCompleted = false;

  void search(String isbn) async {
    _isbn = isbn;
    String isbn13 = "";

    if (_isbn.length == 10) {
      isbn13 = IsbnCheck().convertIsbn10ToIsbn13(_isbn);

      //await classifyAPILookup(_isbn);
      await openLibraryLookup(_isbn);
      await googleBooksAPILookup(_isbn);
      await abeBooksAPILookup(_isbn);

      //await classifyAPILookup(isbn13);
      await openLibraryLookup(isbn13);
      await googleBooksAPILookup(isbn13);
      await abeBooksAPILookup(isbn13);

    } else if (_isbn.length == 13) {

      //await classifyAPILookup(_isbn);
      await openLibraryLookup(_isbn);
      await googleBooksAPILookup(_isbn);
      await abeBooksAPILookup(_isbn);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 500),
          content: Text('Invalid ISBN'),
        ),
      );
      return;
    }

    if (isbn13 == ""){
      writeToCsv(_isbn, _title, _authors, _publisher, _publicationYear, _ddc);
    } else {
      writeToCsv(isbn13, _title, _authors, _publisher, _publicationYear, _ddc);
    }

    _isSearchCompleted = true;
    setState(() {});
  }

  Future<void> classifyAPILookup(String isbn) async {
    String url =
        "http://classify.oclc.org/classify2/Classify?isbn=$isbn&summary=true";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final transformer = Xml2Json();
      transformer.parse(response.body);
      String json = transformer.toParkerWithAttrs();
      if (kDebugMode) {
        print(json);
      }

      var title;
      var authors;
      var ddc;

      if (json != "") {
        if (jsonDecode(json)['classify']['response']['_code'] == '0' ||
            jsonDecode(json)['classify']['response']['_code'] == '4') {
          if (jsonDecode(json)['classify']['work'] != null) {
            authors = jsonDecode(json)['classify']['work']['_author'];
            title = jsonDecode(json)['classify']['work']['_title'];
          } else {
            authors = jsonDecode(json)['classify']['works']['work'][0]['_author'];
            title = jsonDecode(json)['classify']['works']['work'][0]['_title'];
          }

          if (jsonDecode(json)['classify']['recommendations'] != null) {
            ddc = jsonDecode(json)['classify']['recommendations']['ddc']
            ['mostPopular']['_nsfa'];
          }
        }
      }

      setState(() {
        if (title != null) _title = title;
        if (authors != null) _authors = authors;
        if (ddc != null) _ddc = ddc;
      });

      if (kDebugMode) {
        print('Classify API lookup successful');
      }
    } else {
      if (kDebugMode) {
        print('Classify API lookup failed');
      }
    }
  }

  Future<void> openLibraryLookup(String isbn) async {
    String url = "https://openlibrary.org/isbn/$isbn.json";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var title, authors, publisher, publicationYear, coverlink, coverid, ddc;

      if (data['title'] != null) title = data['title'];
      if (data['authors'][0]['name'] != null) authors = data['authors'][0]['name'];
      if (data['publisher'] != null) publisher = data['publisher'];
      if (data['publish_date'] != null) {
        publicationYear = data['publish_date'];
        //publicationYear = publicationYear.substring(publicationYear.length - 4);
      }
      if (data['covers'] != null) coverid = data['covers'][0];
      if (coverid != null) {
        coverlink = "https://covers.openlibrary.org/b/id/$coverid-L.jpg";
      }
      if (data['dewey_decimal_class'] != null) {
        ddc = data['dewey_decimal_class'][0];
        ddc = ddc.replaceAll('/', '');
      }

      setState(() {
        if (title != null && _title == "") _title = title;
        if (authors != null && _authors == "") _authors = authors;
        if (publisher != null && _publisher == "") _publisher = publisher;
        if (publicationYear != null && _publicationYear == "") {
          _publicationYear = publicationYear;
        }
        if (coverlink != null && _coverlink == "") _coverlink = coverlink;
        if (ddc != null && _ddc == "") _ddc = ddc;
      });

      if (kDebugMode) {
        print('Open Library lookup successful');
      }
    } else {
      if (kDebugMode) {
        print('Open Library lookup failed');
      }
    }
  }

  Future<void> googleBooksAPILookup(String isbn) async {
    String url = "https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var volumeInfo, title, authors, publisher, publicationYear, description;

      if (data['items'] != null) {
        volumeInfo = data['items'][0]['volumeInfo'];
        if (volumeInfo['title'] != null) title = volumeInfo['title'];
        if (volumeInfo['authors'] != null) authors = volumeInfo['authors'][0];
        if (volumeInfo['publisher'] != null) publisher = volumeInfo['publisher'];
        if (volumeInfo['publishedDate'] != null) {
          publicationYear = volumeInfo['publishedDate'];
        }
        if (volumeInfo['description'] != null) {
          description = volumeInfo['description'];
        }
      }

      setState(() {
        if (title != null && _title == "") _title = title;
        if (authors != null && _authors == "") _authors = authors;
        if (publisher != null && _publisher == "") _publisher = publisher;
        if (publicationYear != null && _publicationYear == "") {
          _publicationYear = publicationYear;
        }
        if (description != null && _description == "") _description = description;
      });

      if (kDebugMode) {
        print('Google Books API lookup successful');
      }
    } else {
      if (kDebugMode) {
        print('Google Books API lookup failed');
      }
    }
  }

  Future<void> abeBooksAPILookup(String isbn) async {
    final url = Uri.parse('https://www.abebooks.com/servlet/DWRestService/pricingservice');
    final payload = {
      'action': 'getPricingDataByISBN',
      'isbn': isbn,
      'container': 'pricingService-$isbn'
    };

    final response = await http.post(url, body: payload);
    final results = json.decode(response.body);

    if (results['success']) {
      double newPrice, usedPrice, newShipping, usedShipping;

      String bookNew = '', bookUsed = '', destination = '';
      final bestNew = results['pricingInfoForBestNew'];
      final bestUsed = results['pricingInfoForBestUsed'];

      if (bestNew != null) {
        newPrice = double.parse(bestNew['bestPriceInPurchaseCurrencyValueOnly']);
        newShipping = double.parse(bestNew['bestShippingToDestinationPriceInPurchaseCurrencyValueOnly']);
        destination = bestNew['shippingDestinationNameInSurferLanguage'];
        bookNew = (newPrice + newShipping).toStringAsFixed(2);
        if (kDebugMode) {
          print(bookNew);
        }
      }

      if (bestUsed != null) {
        usedPrice = double.parse(bestUsed['bestPriceInPurchaseCurrencyValueOnly']);
        usedShipping = double.parse(bestUsed['bestShippingToDestinationPriceInPurchaseCurrencyValueOnly']);
        destination = bestUsed['shippingDestinationNameInSurferLanguage'];
        bookUsed = (usedPrice + usedShipping).toStringAsFixed(2);
      }

      setState(() {
        if (bookNew != null && _bookNew == "") _bookNew = bookNew;
        if (bookUsed != null && _bookUsed == "") _bookUsed = bookUsed;
        if (destination != null && _destination == "") _destination = destination;
        if (_coverlink == "") {
          _coverlink = "https://pictures.abebooks.com/isbn/$_isbn.jpg";
        }
      });

      if (kDebugMode) {
        print('AbeBooks API lookup successful');
      }
    } else {
      if (kDebugMode) {
        print('AbeBooks API lookup failed');
      }
    }
  }

  void writeToCsv(String isbn, String title, String authors, String publisher,
      String publicationYear, String ddc) async {
    List<List<dynamic>> rows = [
      [isbn, title, authors, publisher, publicationYear, ddc],
    ];

    String csvString = const ListToCsvConverter().convert(rows);

    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/output.csv';

    // Check if the file exists
    bool fileExists = await File(filePath).exists();

    // Check if the current ISBN is a duplicate
    if (fileExists) {
      List<String> lines = await File(filePath).readAsLines();
      for (String line in lines) {
        List<String> fields = line.split(',');
        if (fields.isNotEmpty && fields[0] == isbn) {
          if (kDebugMode) {
            print('Duplicate ISBN. Not writing to CSV.');
          }
          return;
        }
      }
    } else {
      // Write the header if the file is empty
      csvString = 'ISBN,Title,Authors,Publisher,Publication Year,DDC\n$csvString';
    }

    // Append a new line after each record
    csvString += '\n';

    // Write the CSV string to the file
    File file = File(filePath);
    await file.writeAsString(csvString, mode: FileMode.append);
  }

  @override
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: SafeArea(
          child: Column(
            children: [
              if (_coverlink.isNotEmpty)
                Expanded(
                  flex: 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5),
                            BlendMode.darken,
                          ),
                          child: Image.network(
                            _coverlink,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Align(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Image.network(
                            _coverlink,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_title.isNotEmpty)
                Expanded(
                  flex: 12,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (_title.isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                                child: Text(
                                  _title,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 24,
                                    color: Color(0xff000000),
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    if (_authors.isNotEmpty)
                                      Text(
                                        _authors,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    if (_publisher.isNotEmpty)
                                      Text(
                                        _publisher,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_publicationYear.isNotEmpty)
                                Text(
                                  _publicationYear,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    color: Color(0xff000000),
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                            padding: const EdgeInsets.all(0),
                            width: MediaQuery.of(context).size.width,
                            height: 1,
                            decoration: BoxDecoration(
                              color: const Color(0x1f000000),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.zero,
                              border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                            ),
                          ),
                          if (_description.isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _description,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      const Text(
                                        "ISBN",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      Text(
                                        _isbn,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: Text(
                                          "New Price",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                            color: Color(0xff000000),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "US\$ $_bookNew",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      const Text(
                                        "DDC",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      Text(
                                        _ddc,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        child: Text(
                                          "Used Price",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.normal,
                                            color: Color(0xff000000),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "US\$ $_bookUsed",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                            child: Text(
                              "Prices from Abebooks, Shipping to $_destination",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                color: Color(0xff000000),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                        child: FilledButton(
                                          onPressed: () {
                                            launch('https://www.bookfinder.com/isbn/$_isbn/');
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
                                          ),
                                          child: const Text(
                                            "Search Bookfinder",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            ),
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                        child: FilledButton(
                                          onPressed: () {
                                            launch('https://www.abebooks.com/servlet/SearchResults?kn=$_isbn');
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
                                          ),
                                          child: const Text(
                                            "Search Abebooks",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            ),
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                        child: FilledButton(
                                          onPressed: () {
                                            launch('https://flinders.primo.exlibrisgroup.com/discovery/search?query=any,contains,$_isbn&vid=61FUL_INST:FUL&tab=Everything&facet=rtype,exclude,reviews');
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
                                          ),
                                          child: const Text(
                                            "Search Findit\u200b@Flinders",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            ),
                                            maxLines: 3,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate back to the main page
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

}
