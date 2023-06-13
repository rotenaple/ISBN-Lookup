import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:isbn_book_search_test_flutter/utils.dart';
import 'search_result.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? lastScan;
  String? thisScan;

  MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionTimeoutMs: 1000,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

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
                flex: 4,
                child: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(""),
                    ),
                    Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: MobileScanner(
                            fit: BoxFit.cover,
                            controller: controller,
                            onDetect: (capture) {
                              final List<Barcode> barcodes = capture.barcodes;
                              for (final barcode in barcodes) {
                                final String? isbn = barcode.rawValue;
                                if (isbn != null &&
                                    (isbn.length == 10 || isbn.length == 13) &&
                                    IsbnUtils.isValidIsbn(isbn)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SearchResult(isbn: isbn)),
                                  );
                                  return;
                                }
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(milliseconds: 500),
                                  content: Text('No valid ISBN found'),
                                ),
                              );
                            },
                          ),
                        )),
                    const Expanded(
                        flex: 2,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: Text("Scan an ISBN barcode to learn more.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  //fontSize: 16,
                                  color: Color(0xff000000),
                                )))),
                    const Expanded(
                      flex: 5,
                      child: Text(""),
                    ),
                  ],
                )),
            Expanded(
              flex: 1,
              child: Container(),
            )
          ],
        ),
      ),
      floatingActionButton: Platform.isAndroid || Platform.isIOS
          ? FloatingActionButton(
        onPressed: () {},
          child: IconButton(
          icon: const Icon(Icons.keyboard),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      )
          : null,
    );
  }
}