import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ViewCSVPage extends StatelessWidget {
  Future<List<String>> readCSVFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/output.csv';
    final file = File(filePath);
    final exists = await file.exists();

    if (!exists) {
      return []; // Return an empty list to indicate no records yet
    }

    try {
      final csvData = await file.readAsString();
      final lines = csvData.split('\n');
      return lines; // Return a List<String> instead of joining with line breaks
    } catch (e) {
      return []; // Return an empty list if an error occurs
    }
  }

  void copyBookInformationToClipboard(BuildContext context, String title, String author, String publisher, String isbn) {
    final bookInfo = '$title\nAuthor: $author\nPublisher: $publisher\nISBN: $isbn';
    Clipboard.setData(ClipboardData(text: bookInfo));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book information copied')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lookup History'),
      ),
      body: FutureBuilder<List<String>>(
        future: readCSVFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final csvData = snapshot.data!;

            if (csvData.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No records yet',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context); // Return to the previous page
                      },
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: csvData.length - 1, // Subtract 1 to account for the empty line at the end
              itemBuilder: (context, index) {
                final row = csvData[index].split(',');
                final isbn = row[0];
                final title = row[1];
                final author = row[2];
                final publisher = row[3];
                final pubYear = row[4];
                final dewey = row[5];
                return Card(
                  child: ListTile(
                    title: Text(title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('by $author'),
                        Text(publisher.isNotEmpty && pubYear.isNotEmpty ? '$publisher $pubYear' : '$publisher$pubYear'),
                        Text('$isbn $dewey'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        copyBookInformationToClipboard(context, title, author, publisher, isbn);
                        },
                    ),
                  ),
                );

              },
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Failed to load the CSV file.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Return to the previous page
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }


}
