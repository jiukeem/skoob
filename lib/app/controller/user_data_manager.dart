import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../models/book.dart';
import '../models/skoob_user.dart';

class UserDataManager {
  static final UserDataManager _instance = UserDataManager._internal();
  factory UserDataManager() => _instance;
  UserDataManager._internal();
  // code above is for singleton object

  SkoobUser? currentUser;

  void setUser(SkoobUser user) {
    currentUser = user;
  }

  String? get userId => currentUser?.uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<SkoobUser> _userBox = Hive.box<SkoobUser>('userBox');
  final Box<Book> _bookBox = Hive.box<Book>('bookshelfBox');

  Future<bool> updateUserProfile(SkoobUser user, bool isNewUser) async {
    try {
      var userDocument = _firestore
          .collection('user')
          .doc(user.uid)
          .collection('profile')
          .doc('info');

      Map<String, dynamic> dataToUpdate = {
        if (!isNewUser)
          'lastLoggedInAt': DateTime.now().toIso8601String()
        else
          'createdAt': DateTime.now().toIso8601String(),
        ...user.toMap(),
      };
      await userDocument.set(dataToUpdate, SetOptions(merge: true));
      await _userBox.put(user.uid, user);

      return true;
    } catch (e) {
      print("Failed to update Firestore or Hive: $e");
      return false;
    }
  }

  Future<void> addBook(Book book) async {
    if (_bookBox.values.any((b) => b.basicInfo.isbn13 == book.basicInfo.isbn13)) {
      return;
    }

    try {
      // Adding to local Hive database
      _bookBox.add(book);

      // Adding to Firebase - Individual book
      await _firestore.collection('user').doc(userId).collection('bookshelf').doc(book.basicInfo.isbn13).set({
        'title': book.basicInfo.title,
        'author': book.basicInfo.author,
        'translator': book.basicInfo.translator,
        'publisher': book.basicInfo.publisher,
        'category': book.basicInfo.category,
        'isbn13': book.basicInfo.isbn13,
        'comment': book.customInfo.comment,
        'rate': book.customInfo.rate,
        'status': book.customInfo.status.toString(),
      });

      // Adding to Firebase - Collective list
      await _firestore.collection('user').doc(userId).collection('bookshelf').doc('list').set({
        book.basicInfo.isbn13: {
          'title': book.basicInfo.title,
          'author': book.basicInfo.author,
          'translator': book.basicInfo.translator,
          'publisher': book.basicInfo.publisher,
          'category': book.basicInfo.category,
          'isbn13': book.basicInfo.isbn13,
          'comment': book.customInfo.comment,
          'rate': book.customInfo.rate,
          'status': book.customInfo.status.toString(),

        }
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error adding book to Firestore and Hive: $e");
    }
  }

  Future<void> updateBook(Book book) async {
    int index = _bookBox.values.toList().indexWhere((b) => b.basicInfo.isbn13 == book.basicInfo.isbn13);
    if (index != -1) {
      try {
        // Updating local Hive database
        _bookBox.putAt(index, book);

        // Updating Firebase - Individual book document
        await _firestore.collection('user').doc(userId).collection('bookshelf').doc(book.basicInfo.isbn13).update({
          'title': book.basicInfo.title,
          'author': book.basicInfo.author,
          'translator': book.basicInfo.translator,
          'publisher': book.basicInfo.publisher,
          'category': book.basicInfo.category,
          'isbn13': book.basicInfo.isbn13,
          'comment': book.customInfo.comment,
          'rate': book.customInfo.rate,
          'status': book.customInfo.status.toString(),
        });

        // Updating Firebase - Collective list
        await _firestore.collection('user').doc(userId).collection('bookshelf').doc('list').set({
          book.basicInfo.isbn13: {
            'title': book.basicInfo.title,
            'author': book.basicInfo.author,
            'translator': book.basicInfo.translator,
            'publisher': book.basicInfo.publisher,
            'category': book.basicInfo.category,
            'isbn13': book.basicInfo.isbn13,
            'comment': book.customInfo.comment,
            'rate': book.customInfo.rate,
            'status': book.customInfo.status.toString(),
          }
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error updating book in Firestore and Hive: $e");
      }
    }
  }

  Future<void> deleteBook(Book book) async {
    int index = _bookBox.values.toList().indexWhere((b) => b.basicInfo.isbn13 == book.basicInfo.isbn13);
    if (index != -1) {
      try {
        // Deleting from local Hive database
        _bookBox.deleteAt(index);

        // Deleting from Firebase - Individual book document
        await _firestore.collection('user').doc(userId).collection('bookshelf').doc(book.basicInfo.isbn13).delete();

        // Removing from Firebase - Collective list
        await _firestore.collection('user').doc(userId).collection('bookshelf').doc('list').update({
          book.basicInfo.isbn13: FieldValue.delete(),
        });
      } catch (e) {
        print("Error deleting book from Firestore and Hive: $e");
      }
    }
  }
}