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
    var records = box.values.toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Future<void> writeBookRecords(BookRecord bookRecord) async {
    final box = await Hive.openBox<BookRecord>(_boxName);

    var existingRecord = box.get(bookRecord.isbn);

    if (existingRecord != null) {
      var updatedRecord = BookRecord(
        bookRecord.isbn,
        bookRecord.title ?? existingRecord.title,
        bookRecord.author ?? existingRecord.author,
        bookRecord.publisher ?? existingRecord.publisher,
        bookRecord.pubYear ?? existingRecord.pubYear,
        bookRecord.dewey ?? existingRecord.dewey,
        timestamp: DateTime.now(),
      );
      await box.put(bookRecord.isbn, updatedRecord);
      if (kDebugMode) {print('Record with ISBN ${bookRecord.isbn} updated.');}
    } else {
      if (kDebugMode) {print('Record with ISBN ${bookRecord.isbn} inserted.');}
      await box.put(bookRecord.isbn, bookRecord);
    }
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

  @HiveField(6)
  final DateTime timestamp;

  BookRecord(this.isbn, this.title, this.author, this.publisher, this.pubYear, this.dewey, {DateTime? timestamp})
      : this.timestamp = timestamp ?? DateTime.now();
}