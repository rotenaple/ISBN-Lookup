import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ViewCSVPage extends StatelessWidget {
  const ViewCSVPage({super.key});

  Future<String> readCSVFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/output.csv';
      final file = File(filePath);
      final csvData = await file.readAsString();
      final lines = csvData.split('\n');
      return lines.join('\n'); // Add additional line breaks between entries
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lookup History'),
      ),
      body: FutureBuilder<String>(
        future: readCSVFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final csvData = snapshot.data!;
            return SingleChildScrollView(
              child: Text(csvData),
            );
          } else {
            return const Center(
              child: Text(
                'Failed to load the CSV file.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }
}