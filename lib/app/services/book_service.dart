import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../models/book.dart';
import '../models/skoob_user.dart';
import '../repositories/firestore_repository.dart';
import '../repositories/hive_repository.dart';
import '../utils/util_fuctions.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();
  // code above is for singleton object

  final HiveRepository _hiveManager = HiveRepository();
  final FirestoreRepository _firestoreManager = FirestoreRepository();

  SkoobUser? get currentUser => _hiveManager.getUser();
  String get userEmail => currentUser?.email ?? '';

  Future<void> saveBook(Book book) async {
    if (await _hiveManager.isBookExist(book.basicInfo.isbn13)) {
      return;
    }

    await Future.wait([
      _saveBookInHive(book),
      _saveBookInFirestore(book)
    ]);
  }

  Future<void> _saveBookInHive(Book book) async {
    await _hiveManager.addBook(book);
    await updateLastModifiedTimeInHive();
  }

  Future<void> _saveBookInFirestore(Book book) async {
    final mapData = createMapFromSkoobBook(book);
    final String isbn13 = book.basicInfo.isbn13;

    await _firestoreManager.saveBook(bookData: mapData, email: userEmail, isbn13: isbn13);
    await updateLastModifiedTimeInFirestore();
  }

  Future<void> deleteBook(Book book) async {
    await Future.wait([
      _deleteBookInHive(book),
      _deleteBookInFirestore(book)
    ]);
  }

  Future<void> _deleteBookInHive(Book book) async {
    await _hiveManager.deleteBook(book);
    await updateLastModifiedTimeInHive();
  }

  Future<void> _deleteBookInFirestore(Book book) async {
    await _firestoreManager.deleteBook(book, userEmail);
    await updateLastModifiedTimeInFirestore();
  }

  Future<void> updateLastModifiedTimeInHive() async {
    await _hiveManager.updateLastModifiedTimeInHive();
  }

  Future<DateTime?> getLastModifiedTimeInHive() async {
    String? time = _hiveManager.getLastModifiedTimeInHive();
    return time != null ? DateTime.parse(time) : null;
  }

  Future<void> updateLastModifiedTimeInFirestore() async {
    await _firestoreManager.updateUserProfile({'lastModifiedAt': DateTime.now().toIso8601String()}, userEmail);
  }

  Future<DateTime?> getLastModifiedTimeInFirestore() async {
    final doc = await _firestoreManager.getUserProfile(userEmail);
    if (isDocumentDataValid(doc)) {
      Map<String, dynamic> userData = doc!.data() as Map<String, dynamic>;
      String? time = userData['lastModifiedAt'] as String?;
      return time != null ? DateTime.parse(time) : null;
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_getLastModifiedTimeInFirestore::document is null or has no data');
      return null;
    }
  }

  Future<void> syncBookshelfFromLocal() async {
    Map<String, Book> localBooks = _hiveManager.getBookshelf();
    await _firestoreManager.updateBookshelf(localBooks, userEmail);
    await updateLastModifiedTimeInFirestore();
  }

  Future<void> syncBookshelfFromServer() async {
    QuerySnapshot? querySnapshot = await _firestoreManager.getBookshelf(userEmail);
    if (querySnapshot == null) {
      FirebaseCrashlytics.instance.log('UserDataManager_syncBookshelfFromServer::querySnapshot is null');
      return;
    }

    List<Book> bookList = [];
    for (var doc in querySnapshot.docs) {
      if (doc.id == "list") continue; // Skip the 'list' document
      if (doc.data() != null && doc.data() is Map<String, dynamic>) {
        Book book = Book.fromFirestore(doc.data()! as Map<String, dynamic>);
        bookList.add(book);
      } else {
        FirebaseCrashlytics.instance.log('UserDataManager_syncBookshelfFromServer::${doc.id} is null');
      }
    }

    await _hiveManager.updateBookshelf(bookList);
    await updateLastModifiedTimeInHive();
  }

  Future<List<Book>> getFriendBookshelf(String email) async {
    DocumentSnapshot? doc = await _firestoreManager.getBookshelfBrief(email);

    List<Book> bookList = [];
    if (isDocumentDataValid(doc)) {
      final map = doc!.data() as Map<String, dynamic>;
      final books = map.values;
      for (final value in books) {
        Book book = Book.fromFirestore(value as Map<String ,dynamic>);
        bookList.add(book);
      }
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_getFriendBookshelf::document is null or has no data: $email');
    }
    return bookList;
  }
}