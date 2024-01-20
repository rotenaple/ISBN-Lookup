import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'book_data.dart';
import 'theme.dart';

class LookupHistoryPage extends StatefulWidget {
  const LookupHistoryPage({Key? key}) : super(key: key);

  @override
  _LookupHistoryPageState createState() => _LookupHistoryPageState();
}

class _LookupHistoryPageState extends State<LookupHistoryPage> {
  final BookRecordsManager logic = BookRecordsManager();
  List<BookRecord> records = [];

  @override
  void initState() {
    super.initState();
    refreshPage();
  }

  Future<void> refreshPage() async {
    var data = await logic.fetchBookRecords();
    setState(() {
      records = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColour,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeaderWidget(),
            Expanded(
              child: dataList(
                dataFuture: logic.fetchBookRecords(),
                onRefresh: () {
                  refreshPage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Text('Lookup History', style: AppTheme.h1),
    );
  }
}

class dataList extends StatelessWidget {
  final Future<List<BookRecord>> dataFuture;
  final VoidCallback onRefresh;

  const dataList(
      {Key? key, required this.dataFuture, required this.onRefresh})
      : super(key: key);

  void _deleteRecord(BuildContext context, String isbn) async {
    await BookRecordsManager().deleteBookRecords(isbn);
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookRecord>>(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          final records = snapshot.data!;
          return records.isEmpty
              ? Center(child: Text('No records yet', style: AppTheme.h2))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return LookupRecordCard(
                      record: records[index],
                      onDelete: () =>
                          _deleteRecord(context, records[index].isbn),
                    );
                  },
                );
        } else {
          return Center(
              child: Text('Failed to read database.', style: AppTheme.h2));
        }
      },
    );
  }
}

class LookupRecordCard extends StatelessWidget {
  final BookRecord record;
  final VoidCallback onDelete;

  const LookupRecordCard(
      {Key? key, required this.record, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.altBackgroundColour,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
        child: ListTile(
          title: _buildTitleText(record.title),
          subtitle: _buildSubtitle(record.author, record.publisher, record.isbn,
              record.dewey, record.pubYear),
          trailing: _buildActionButtons(context, record),
        ),
      ),
    );
  }

  Widget _buildTitleText(String title) {
    return Text(title, style: AppTheme.boldTextStyle);
  }

  Widget _buildSubtitle(String author, String publisher, String isbn,
      String dewey, String pubYear) {
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
      publisher.isNotEmpty && pubYear.isNotEmpty
          ? '$publisher $pubYear'
          : '$publisher$pubYear',
      style: AppTheme.normalTextStyle,
    );
  }

  Widget _buildIsbnDeweyText(String isbn, String dewey) {
    return Text('$isbn $dewey', style: AppTheme.normalTextStyle);
  }

  Row _buildActionButtons(BuildContext context, BookRecord record) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
            Icons.copy, () => copyBookInformationToClipboard(context, record)),
        _buildIconButton(
            Icons.delete, () => _showDeleteDialog(context, record.isbn)),
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
        content: Text('Are you sure you want to delete this record?',
            style: AppTheme.dialogContentStyle),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTheme.dialogButtonStyle)),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              style: AppTheme.filledWarningButtonStyle,
              child: const Text('Delete')),
        ],
      ),
    );
  }

  void copyBookInformationToClipboard(BuildContext context, BookRecord record) {
    final bookInfo =
        '${record.title}\nAuthor: ${record.author}\nPublisher: ${record.publisher}\nISBN: ${record.isbn}';
    Clipboard.setData(ClipboardData(text: bookInfo));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Book information copied')));
  }
}
