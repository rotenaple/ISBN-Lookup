// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isbnsearch_flutter/theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:isbnsearch_flutter/isbn_check.dart';
import 'search_result.dart';

class BarcodeSearch extends StatefulWidget {
  const BarcodeSearch({super.key});

  @override
  BarcodeSearchState createState() => BarcodeSearchState();
}

class BarcodeSearchState extends State<BarcodeSearch> {
  String? lastScan;
  String? thisScan;
  static bool isScanning = false; // Flag to track scanning status

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
          child: Padding(
              padding: EdgeInsets.fromLTRB(36, 80, 36, 80),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: MobileScanner(
                          fit: BoxFit.cover,
                          controller: controller,
                          onDetect: (capture) {
                            if (isScanning)
                              return; // Ignore if already scanning
                            if (kDebugMode) {
                              print("Scanning");
                            }
                            isScanning = true; // Set scanning status to true

                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              final String? isbn = barcode.rawValue;
                              IsbnCheck isbnCheck = IsbnCheck();
                              if (isbn != null &&
                                  (isbn.length == 10 || isbn.length == 13) &&
                                  isbnCheck.isValidIsbnFormat(isbn)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SearchResult(isbn: isbn),
                                  ),
                                ).then((_) {});
                                return;
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(milliseconds: 500),
                                content: Text(
                                  'No Valid ISBN Found',
                                  style: AppTheme.normalTextStyle,
                                ),
                                backgroundColor: AppTheme.unselectedColour,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Text(
                        "Scan an ISBN Barcode to Learn More",
                        style: AppTheme.h2,
                      ),
                    )
                  ],
                ),
              ))),
    );
  }
}
