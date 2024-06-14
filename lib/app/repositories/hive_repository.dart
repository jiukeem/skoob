import 'package:hive/hive.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/skoob_user.dart';
import 'package:skoob/app/services/third_party/firebase_analytics.dart';

import '../../config/config.dart';

class HiveRepository {
  static final HiveRepository _instance = HiveRepository._internal();
  factory HiveRepository() => _instance;
  HiveRepository._internal();

  late Box<SkoobUser> _userBox;
  late Box<Book> _bookBox;
  late Box<String> _settingBox;

  final _userBoxKey = 'user';
  final _settingBoxKey = 'lastModifiedAt';

  Future<void> openBox() async {
    _userBox = await Hive.openBox<SkoobUser>(userBoxName);
    _bookBox = await Hive.openBox<Book>(bookBoxName);
    _settingBox = await Hive.openBox<String>(settingBoxName);

    // v1.0.0 used auto-generated key in bookBox
    await _migrateOldBooksIfNeeded();
  }

  Future<void> _migrateOldBooksIfNeeded() async {
    final oldBookBox = await Hive.openBox<Book>(oldBookBoxName);

    if (oldBookBox.isNotEmpty) {
      for (int i = 0; i < oldBookBox.length; i++) {
        final book = oldBookBox.getAt(i);
        if (book != null) {
          final key = book.basicInfo.isbn13;
          print(key);
          print(key);
          print(key);
          print(key);
          await _bookBox.put(key, book.clone());
        }
      }
      await oldBookBox.clear();
    }
    await oldBookBox.close();
  }

  Future<void> dispose() async {
    await _bookBox.close();
    await _userBox.close();
    await _settingBox.close();
    return;
  }

  Future<void> setUser(SkoobUser user) async {
    await _userBox.put(_userBoxKey, user);
    AnalyticsService.setUser(user);
    return;
  }

  SkoobUser? getUser()  {
    return _userBox.get(_userBoxKey);
  }

  Future<bool> hasUser() async {
    return _userBox.isNotEmpty;
  }

  Future<bool> isBookExist(String isbn13) async {
    return _bookBox.values.contains(isbn13);
  }

  Future<void> addBook(Book book) async {
    final key = book.basicInfo.isbn13;
    await _bookBox.put(key, book);
    // TODO v1.0.0 doesn't have key. only index
    return;
  }

  Future<void> saveBook(Book book) async {
    final key = book.basicInfo.isbn13;
    await _bookBox.put(key, book);
  }

  Future<void> deleteBook(Book book) async {
    final key = book.basicInfo.isbn13;
    _bookBox.delete(key);
  }

  Future<void> updateLastModifiedTimeInHive() async {
    await _settingBox.put(_settingBoxKey, DateTime.now().toIso8601String());
  }

  String? getLastModifiedTimeInHive() {
    return _settingBox.get(_settingBoxKey);
  }

  Map<String, Book> getBookshelf()  {
    return _bookBox.toMap() as Map<String, Book>;
  }

  Future<void> updateBookshelf(List<Book> bookList) async {
    await _bookBox.clear();

    for (Book book in bookList) {
      await _bookBox.put(book.basicInfo.isbn13, book);
    }
  }

  Future<void> clearAllLocalData() async {
    await _userBox.clear();
    await _bookBox.clear();
    await _settingBox.clear();
  }
}