import 'package:barcode/barcode.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:isbnsearch_flutter/barcode_search.dart';
import 'package:isbnsearch_flutter/theme.dart';
import 'dart:ui';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'format_date.dart';
import 'isbn_check.dart';
import 'title_case_converter.dart';
import 'package:html/dom.dart' as dom;

String extractTextContent(dom.Element? element) {
  if (element == null) {
    return '';
  }

  final buffer = StringBuffer();
  for (var node in element.nodes) {
    if (node is dom.Text) {
      buffer.write(node.text);
    } else if (node is dom.Element) {
      buffer.write(extractTextContent(node));
    }
  }
  return buffer.toString();
}

class SearchResult extends StatefulWidget {
  final String isbn;

  const SearchResult({super.key, required this.isbn});

  @override
  SearchResultState createState() => SearchResultState();
}

class SearchResultState extends State<SearchResult> {
  String _title = '';
  String _authors = '';
  String _isbn = '';
  String _publisher = '';
  String _publicationYear = '';
  String _description = '';
  String _coverlink = '';
  String _ddc = '';
  String _bookNew = '', _bookUsed = '', _destination = '';
  String _svgBarcode = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    search(widget.isbn);
  }

  void search(String isbn) async {
    _isbn = isbn;
    String isbn13 = "";

    if (_isbn.length == 10) {
      isbn13 = IsbnCheck().convertIsbn10ToIsbn13(_isbn);

      await openLibraryLookup(_isbn);
      await googleBooksAPILookup(_isbn);
      await abeBooksAPILookup(_isbn);

      //await oclcClassifyLookup(isbn13);
      await openLibraryLookup(isbn13);
      await googleBooksAPILookup(isbn13);
      await abeBooksAPILookup(isbn13);
    } else if (_isbn.length == 13) {
      //await oclcClassifyLookup(_isbn);
      await openLibraryLookup(_isbn);
      await googleBooksAPILookup(_isbn);
      await abeBooksAPILookup(_isbn);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppTheme.customSnackbar('Invalid ISBN'));
      return;
    }

    _title = TitleCaseConverter.convertToTitleCase(_title);
    _authors = TitleCaseConverter.convertToTitleCase(_authors);
    _publisher = TitleCaseConverter.convertToTitleCase(_publisher);

    if (isbn13 != "") {
      _isbn = isbn13;
    }

    final svgBarcode = Barcode.isbn()
        .toSvg(_isbn, width: 250, height: 80, fontHeight: 0, textPadding: 0);
    _svgBarcode = svgBarcode;

    ExtractYear extractYear = ExtractYear();
    _publicationYear = extractYear.extract(_publicationYear);

    writeToCsv(_isbn, _title, _authors, _publisher, _publicationYear, _ddc);

    setState(() {});
    _isLoading = false;
  }

  String extractTextContent(dom.Element? element) {
    if (element == null) {
      return '';
    }

    final buffer = StringBuffer();
    for (var node in element.nodes) {
      if (node is dom.Text) {
        buffer.write(node.text);
      } else if (node is dom.Element) {
        buffer.write(extractTextContent(node));
      }
    }
    return buffer.toString();
  }

  Future<void> openLibraryLookup(String isbn) async {
    String url = "https://openlibrary.org/isbn/$isbn.json";
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var title, authors, publisher, publicationYear, imgURL, coverid, ddc;

      if (data['title'] != null) title = data['title'];
      if (data['authors'][0]['name'] != null) {
        authors = data['authors'][0]['name'];
      }
      if (data['publisher'] != null) publisher = data['publisher'];
      if (data['publish_date'] != null) {
        publicationYear = data['publish_date'];
        //publicationYear = publicationYear.substring(publicationYear.length - 4);
      }
      if (data['covers'] != null) coverid = data['covers'][0];
      if (coverid != null) {
        imgURL = "https://covers.openlibrary.org/b/id/$coverid-L.jpg";
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
        if (imgURL != null && _coverlink == "") _coverlink = imgURL;
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
        if (volumeInfo['publisher'] != null) {
          publisher = volumeInfo['publisher'];
        }
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
        if (description != null && _description == "") {
          _description = description;
        }
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
    final url = Uri.parse(
        'https://www.abebooks.com/servlet/DWRestService/pricingservice');
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
        newPrice =
            double.parse(bestNew['bestPriceInPurchaseCurrencyValueOnly']);
        newShipping = double.parse(bestNew[
            'bestShippingToDestinationPriceInPurchaseCurrencyValueOnly']);
        destination = bestNew['shippingDestinationNameInSurferLanguage'];
        bookNew = (newPrice + newShipping).toStringAsFixed(2);
        if (kDebugMode) {
          print(bookNew);
        }
      }

      if (bestUsed != null) {
        usedPrice =
            double.parse(bestUsed['bestPriceInPurchaseCurrencyValueOnly']);
        usedShipping = double.parse(bestUsed[
            'bestShippingToDestinationPriceInPurchaseCurrencyValueOnly']);
        destination = bestUsed['shippingDestinationNameInSurferLanguage'];
        bookUsed = (usedPrice + usedShipping).toStringAsFixed(2);
      }

      setState(() {
        if (_bookNew == "") _bookNew = bookNew;
        if (_bookUsed == "") _bookUsed = bookUsed;
        if (_destination == "") _destination = destination;
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

  Future<List<List<dynamic>>> readCSVFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/output.csv';
      final file = File(filePath);
      final csvData = await file.readAsString();
      final csvList = const CsvToListConverter().convert(csvData);
      return csvList;
    } catch (e) {
      return [];
    }
  }

  Future<void> initCsv() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/output.csv';
    final file = File(filePath);
    final exists = await file.exists();
    if (!exists) {
      await file.create(); // Create a blank file without writing any content.
    }
  }

  Future<void> writeToCsv(String isbn, String title, String authors,
      String publisher, String publicationYear, String ddc) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/output.csv';
    final file = File(filePath);
    final exists = await file.exists();
    if (!exists) {
      await initCsv();
    }

    // Check if the current ISBN is a duplicate
    final lines = await file.readAsLines();
    for (String line in lines) {
      final fields = line.split(',');
      if (fields.isNotEmpty && fields[0] == isbn) {
        if (kDebugMode) {
          print('Duplicate ISBN. Not writing to CSV.');
        }
        return;
      }
    }
    var replaceTo = '';

    final row = [
      isbn.replaceAll(',', replaceTo),
      title.replaceAll(',', replaceTo),
      authors.replaceAll(',', replaceTo),
      publisher.replaceAll(',', replaceTo),
      publicationYear.replaceAll(',', replaceTo),
      ddc.replaceAll(',', replaceTo)
    ];
    final csvString = const ListToCsvConverter().convert([row]);
    final csvLine = '$csvString\n';
    await file.writeAsString(csvLine, mode: FileMode.append);
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the orientation is landscape
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    Widget content = isLandscape
        ? Row(
            // In landscape mode, use Row
            children: buildChildren(isLandscape),
          )
        : Column(
            // In portrait mode, use Column
            children: buildChildren(isLandscape),
          );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColour,
      body: SafeArea(
        child: Visibility(
          visible: !_isLoading,
          child: SafeArea(child: content),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColour,
        onPressed: () {
          BarcodeSearchState.isScanning = false;
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back, color: AppTheme.altBackgroundColourLight),
      ),
    );
  }

  List<Widget> buildChildren(bool isLandscape) {
    List<Widget> children = [];
    if (_coverlink.isNotEmpty) {
      children.add(
        Expanded(
          flex: 5,
          child: buildImageBlock(isLandscape),
        ),
      );
    }
    if (_title.isNotEmpty) {
      children.add(
        Expanded(
          flex: 12,
          child: buildTextBlock(),
        ),
      );
    }
    return children;
  }

  Widget buildImageBlock(bool isLandscape) {
    return Stack(
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
              fit: isLandscape ? BoxFit.fitHeight : BoxFit.fitWidth,
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
    );
  }

  Widget buildTextBlock() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          children: [
            if (_title.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 20, 5),
                  child: Text(
                    _title,
                    style: AppTheme.h1,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_authors.isNotEmpty)
                        Text(
                          _authors,
                          style: AppTheme.boldTextStyle,
                        ),
                      if (_publisher.isNotEmpty)
                        Text(
                          _publisher,
                          style: AppTheme.boldTextStyle,
                        ),
                    ],
                  ),
                ),
                if (_publicationYear.isNotEmpty)
                  Text(
                    _publicationYear,
                    style: AppTheme.boldTextStyle,
                  ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              padding: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: 1,
              decoration: BoxDecoration(
                color: const Color(0x1f000000),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: AppTheme.unselectedColour, width: 1),
              ),
            ),
            if (_description.isNotEmpty)
              Text(
                _description,
                textAlign: TextAlign.justify,
                overflow: TextOverflow.clip,
                style: AppTheme.condTextStyle,
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
                        ResultTextBlock(
                          title: "ISBN",
                          content: _isbn,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: ResultTextBlock(
                            title: "New Price",
                            content: "US\$ $_bookNew",
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
                        ResultTextBlock(
                          title: "DDC",
                          content: _ddc,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: ResultTextBlock(
                            title: "Used Price",
                            content: "US\$ $_bookUsed",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: Text(
                "Prices from Abebooks, Shipping to $_destination",
                style: AppTheme.normalTextStyle,
                textAlign: TextAlign.start,
                overflow: TextOverflow.clip,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 170,
                        child: SearchIconButton(
                          text: "Bookfinder",
                          icon: Icons.search,
                          link: 'https://www.bookfinder.com/isbn/$_isbn/',
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: SearchIconButton(
                          text: "Abebooks",
                          icon: Icons.search,
                          link:
                          'https://www.abebooks.com/servlet/SearchResults?kn=$_isbn',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 170,
                        child: SearchIconButton(
                          text: "Open Library",
                          icon: Icons.search,
                          link: 'https://openlibrary.org/isbn/$_isbn',
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: SearchIconButton(
                          text: "Goodreads",
                          icon:
                          Icons.search, // This is the magnifying glass icon
                          link: 'https://www.goodreads.com/search?q=$_isbn',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        child: SearchIconButton(
                          text: "Findit@Flinders",
                          icon:
                          Icons.search, // This is the magnifying glass icon
                          link:
                          'https://flinders.primo.exlibrisgroup.com/discovery/search?query=any,contains,$_isbn&vid=61FUL_INST:FUL&tab=Everything&facet=rtype,exclude,reviews',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(75, 10, 75, 10),
                child: SvgPicture.string(_svgBarcode, color: AppTheme.textColour,)),
          ],
        ),
      ),
    );
  }
}
