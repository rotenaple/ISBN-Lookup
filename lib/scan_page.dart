import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isbnsearch_flutter/theme.dart';
import 'package:isbnsearch_flutter/view_csv.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:isbnsearch_flutter/isbn_check.dart';
import 'search_result.dart';


class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  ScanPageState createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
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
                            if (isScanning) return; // Ignore if already scanning
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
                                    builder: (context) => SearchResult(isbn: isbn),
                                  ),
                                ).then((_) {
                                });
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
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Text(
                          "Scan an ISBN barcode to learn more.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            //fontSize: 16,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 5,
                      child: Text(""),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              )
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
                FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: AppTheme.primaryColour,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard),
                    color: Color(0xffFFFFFF),
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
