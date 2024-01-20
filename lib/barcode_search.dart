import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'isbn_check.dart';
import 'search_result.dart';
import 'theme.dart';

class BarcodeSearch extends StatefulWidget {
  const BarcodeSearch({super.key});

  @override
  BarcodeSearchState createState() => BarcodeSearchState();
}

class BarcodeSearchState extends State<BarcodeSearch> {
  String? lastScan;
  String? thisScan;
  static bool isScanning = false;

  MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionTimeoutMs: 1000,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  String hasCameraPermission = "loading";

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) {
      setState(() => hasCameraPermission = 'true');
    } else {
      setState(() => hasCameraPermission = 'false');

      print("status");
      print(status);

      print("hasCameraPermission");
      print(hasCameraPermission);

    }
  }

  @override
  Widget build(BuildContext context) {

    switch (hasCameraPermission) {
      case 'true':
        return _buildSuccessful();
      case 'false':
        return _buildFailed();
      case 'loading':
      default:
        return Scaffold(backgroundColor: AppTheme.backgroundColour);
    }
  }

  Widget _buildSuccessful() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColour,
      body: Padding(
          padding: const EdgeInsets.fromLTRB(36, 80, 36, 80),
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
                        if (isScanning) {
                          return; // Ignore if already scanning
                        }
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
                            ).then((_) {});
                            return;
                          }
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          AppTheme.customSnackbar('No Valid ISBN Found'),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Text(
                    "Scan an ISBN Barcode",
                    style: AppTheme.h2,
                  ),
                )
              ],
            ),
          ))
    );
  }

  Widget _buildFailed() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColour,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.info,
              color: AppTheme.altPrimColour,
              size: 64,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Text(
                'Permission to use the camera is required for this function.',
                textAlign: TextAlign.center,
                style: AppTheme.dialogContentStyle,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
                exit(0);
              },
              style: AppTheme.filledButtonStyle,
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
