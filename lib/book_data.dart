import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

part 'book_data.g.dart';

class BookRecordsManager {
  static const String _boxName = 'bookRecordsBox';
  late Box box;

  Future<void> initBookRecords() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    box = await Hive.openBox<BookRecord>(_boxName);
  }

  Future<List<BookRecord>> fetchBookRecords() async {
    final box = await Hive.openBox<BookRecord>(_boxName);
    return box.values.toList();
  }

  Future<void> writeBookRecords(BookRecord bookRecord) async {
    final box = await Hive.openBox<BookRecord>(_boxName);

    // Check if the current ISBN is a duplicate
    if (box.values.any((record) => record.isbn == bookRecord.isbn)) {
      if (kDebugMode) {
        print('Duplicate ISBN. Not writing to DB.');
      }
      return;
    }

    await box.put(bookRecord.isbn, bookRecord);
  }

  Future<void> deleteBookRecords(String isbn) async {
    final box = await Hive.openBox<BookRecord>(_boxName);
    await box.delete(isbn);
  }
}

@HiveType(typeId: 0)
class BookRecord extends HiveObject {
  @HiveField(0)
  final String isbn;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String publisher;

  @HiveField(4)
  final String pubYear;

  @HiveField(5)
  final String dewey;

  BookRecord(this.isbn, this.title, this.author, this.publisher, this.pubYear, this.dewey);
}