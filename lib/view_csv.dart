import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
var printed = false;

class ViewCSVPage extends StatefulWidget {
  @override
  _ViewCSVPageState createState() => _ViewCSVPageState();
}

class _ViewCSVPageState extends State<ViewCSVPage> {
  List<String> csvData = [];

  @override
  void initState() {
    super.initState();
    refreshPage();
  }


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
      if (kDebugMode) {

        if (!printed) {
          print(csvData);
        }
      }
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

  Future<void> refreshPage() async {
    final data = await readCSVFile();
    setState(() {
      csvData = data;
    });
    printed = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Container(
                color: Colors.blue, // Set the background color to blue
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: const Text(
                  'Lookup History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: readCSVFile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData) {
                    final csvData = snapshot.data!;

                    if (csvData.isEmpty || csvData.every((line) => line.trim().isEmpty)) {
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
                      itemCount: csvData.length - 1,
                      itemBuilder: (context, index) {
                        final row = csvData[index].split(',');
                        final isbn = row[0];
                        final title = row[1];
                        final author = row[2];
                        final publisher = row[3];
                        final pubYear = row[4];
                        final dewey = row[5];

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                              child: ListTile(
                                title: Text(title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (author.trim().isNotEmpty) Text('by $author') else const Text(""),
                                    Text(publisher.isNotEmpty && pubYear.isNotEmpty ? '$publisher $pubYear' : '$publisher$pubYear'),
                                    Text('$isbn $dewey'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.copy),
                                      onPressed: () {
                                        copyBookInformationToClipboard(context, title, author, publisher, isbn);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            content: Text('Are you sure you want to delete this record?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context), // Cancel the deletion
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context); // Close the dialog
                                                  deleteRowFromCSV(isbn);
                                                },
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
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
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // Align the column to the bottom
            children: [
              if (kDebugMode) // Conditionally show the button in debug mode
                FloatingActionButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text('Are you sure you want to delete all records?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(false); // Return false to indicate cancellation
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.red, // Set the text color to red
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(true); // Return true to indicate confirmation
                              },
                            )
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      final directory = await getApplicationDocumentsDirectory();
                      final filePath = '${directory.path}/output.csv';
                      final file = File(filePath);
                      final exists = await file.exists();

                      if (exists) {
                        await file.delete();
                        refreshPage(); // Refresh the page after deleting the file
                      }
                    }
                  },
                  backgroundColor: Colors.red, // Set the button color to red
                  child: const Icon(Icons.delete_forever),
                ),
              const SizedBox(height: 16.0), // Add spacing between the two FloatingActionButton
              FloatingActionButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: const Icon(Icons.arrow_back),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteRowFromCSV(String isbn) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/output.csv';
    final file = File(filePath);
    final exists = await file.exists();

    if (!exists) {
      return;
    }

    try {
      final csvData = await file.readAsLines();

      // Find the index of the row to be deleted
      final index = csvData.indexWhere((line) => line.split(',')[0] == isbn);

      if (index != -1) {
        // Remove the row at the found index, including the line break
        csvData.removeAt(index);

        // Join the updated CSV data back into a string
        final updatedCsvString = csvData.join('\n') + '\n';

        // Write the updated CSV string back to the file
        await file.writeAsString(updatedCsvString);

        // Refresh the page
        refreshPage();
      }
    } catch (e) {
      print('Failed to delete row from CSV: $e');
    }
  }

}
