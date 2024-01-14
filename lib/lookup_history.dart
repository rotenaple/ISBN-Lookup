import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isbnsearch_flutter/theme.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

var printed = false;

class LookupHistoryPage extends StatefulWidget {
  const LookupHistoryPage({Key? key});

  @override
  _LookupHistoryPageState createState() => _LookupHistoryPageState();
}

class _LookupHistoryPageState extends State<LookupHistoryPage> {
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

  void copyBookInformationToClipboard(BuildContext context, String title,
      String author, String publisher, String isbn) {
    final bookInfo =
        '$title\nAuthor: $author\nPublisher: $publisher\nISBN: $isbn';
    Clipboard.setData(ClipboardData(text: bookInfo));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book information copied')),
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
      backgroundColor: AppTheme.backgroundColour,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                  'Lookup History',
                  style: AppTheme.h1,
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

                    if (csvData.isEmpty ||
                        csvData.every((line) => line.trim().isEmpty)) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No records yet',
                              style: AppTheme.h2,
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
                          child: buildLookupRecordCard(title, author, publisher, isbn, dewey, pubYear),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Failed to load the CSV file.',
                            style: AppTheme.h2,
                          ),
                          const SizedBox(height: 16),
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
        final updatedCsvString = '${csvData.join('\n')}\n';

        // Write the updated CSV string back to the file
        await file.writeAsString(updatedCsvString);

        // Refresh the page
        refreshPage();
      }
    } catch (e) {
      print('Failed to delete row from CSV: $e');
    }
  }

  Widget buildLookupRecordCard(title, author, publisher, isbn, dewey, pubYear) {
    return Card(
      color: AppTheme.altBackgroundColour,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
        child: ListTile(
          title: _buildTitleText(title),
          subtitle: _buildSubtitle(author, publisher, isbn, dewey, pubYear),
          trailing: _buildActionButtons(context, title, author, publisher, isbn),
        ),
      ),
    );
  }

  Widget _buildTitleText(String title) {
    return Text(
      title,
      style: AppTheme.boldTextStyle,
    );
  }

  Widget _buildSubtitle(String author, String publisher, String isbn, String dewey, String pubYear) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAuthorText(author),
        _buildPublisherYearText(publisher, pubYear),
        _buildIsbnDeweyText(isbn, dewey),
      ],
    );
  }

  Widget _buildAuthorText(String author) {
    return author.trim().isNotEmpty
        ? Text('by $author', style: AppTheme.normalTextStyle)
        : const Text("");
  }

  Widget _buildPublisherYearText(String publisher, String pubYear) {
    return Text(
      publisher.isNotEmpty && pubYear.isNotEmpty ? '$publisher $pubYear' : '$publisher$pubYear',
      style: AppTheme.normalTextStyle,
    );
  }

  Widget _buildIsbnDeweyText(String isbn, String dewey) {
    return Text('$isbn $dewey', style: AppTheme.normalTextStyle);
  }

  Row _buildActionButtons(BuildContext context, String title, String author, String publisher, String isbn) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(Icons.copy, () => copyBookInformationToClipboard(context, title, author, publisher, isbn)),
        _buildIconButton(Icons.delete, () => _showDeleteDialog(context, isbn)),
      ],
    );
  }

  IconButton _buildIconButton(IconData icon, Function()? onPressed) {
    return IconButton(
      icon: Icon(icon, color: AppTheme.textColour),
      onPressed: onPressed,
    );
  }

  void _showDeleteDialog(BuildContext context, String isbn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.altBackgroundColour,
        title: Text("Delete Record", style: AppTheme.boldTextStyle),
        content: Text('Are you sure you want to delete this record?', style: AppTheme.dialogContentStyle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: AppTheme.dialogButtonStyle)),
          ElevatedButton(onPressed: () { Navigator.pop(context); deleteRowFromCSV(isbn); }, style: AppTheme.filledWarningButtonStyle, child: const Text('Delete')),
        ],
      ),
    );
  }

}

class HeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Text(
        'Lookup History',
        style: AppTheme.h1,
      ),
    );
  }
}

class CSVDataList extends StatelessWidget {
  final Future<List<String>> csvDataFuture;

  const CSVDataList({super.key, required this.csvDataFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: csvDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          final csvData = snapshot.data!;
          return _buildCSVDataView(csvData, context);
        } else {
          return _buildErrorView();
        }
      },
    );
  }

  Widget _buildCSVDataView(List<String> csvData, BuildContext context) {
    if (csvData.isEmpty || csvData.every((line) => line.trim().isEmpty)) {
      return Center(
        child: Text('No records yet', style: AppTheme.h2),
      );
    }

    return ListView.builder(
      itemCount: csvData.length - 1,
      itemBuilder: (context, index) {
        return CSVItem(row: csvData[index].split(','));
      },
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Text('Failed to load the CSV file.', style: AppTheme.h2),
    );
  }
}

class CSVItem extends StatelessWidget {
  final List<String> row;

  const CSVItem({super.key, required this.row});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Card(
        color: AppTheme.altBackgroundColour,
        child: const ListTile(
          // ... rest of the ListTile code ...
        ),
      ),
    );
  }
}
