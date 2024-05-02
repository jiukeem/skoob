import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/skoob_user.dart';

class UserDataManager {
  static final UserDataManager _instance = UserDataManager._internal();
  factory UserDataManager() => _instance;
  UserDataManager._internal();
  // code above is for singleton object

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Box<SkoobUser> _userBox;
  late Box<Book> _bookBox;
  late Box<String> _settingBox;
  SkoobUser? currentUser;
  String? get userId => currentUser?.uid;

  Future<void> initBox() async {
    _bookBox = await Hive.openBox<Book>('bookshelfBox');
    _userBox = await Hive.openBox<SkoobUser>('userBox');
    _settingBox = await Hive.openBox<String>('settingBox');
  }

  void setUser(SkoobUser user) {
    currentUser = user;
  }

  void dispose() {
    _bookBox.close();
    _userBox.close();
  }

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

  Map<String, String> _createMapFromSkoobBook(Book book) {
    return {
      'title': book.basicInfo.title,
      'author': book.basicInfo.author,
      'publisher': book.basicInfo.publisher,
      'pubDate': book.basicInfo.pubDate,
      'description': book.basicInfo.description,
      'coverImageUrl': book.basicInfo.coverImageUrl,
      'infoUrl': book.basicInfo.infoUrl,
      'category': book.basicInfo.category,
      'isbn13': book.basicInfo.isbn13,
      'isbn10': book.basicInfo.isbn10,
      'translator': book.basicInfo.translator,
      'addedDate': book.customInfo.addedDate,
      'status': book.customInfo.status.toString(),
      'startReadingDate': book.customInfo.startReadingDate,
      'finishReadingDate': book.customInfo.finishReadingDate,
      'rate': book.customInfo.rate,
      'comment': book.customInfo.comment,
    };
  }

  Future<void> addBook(Book book) async {
    if (_bookBox.values.any((b) => b.basicInfo.isbn13 == book.basicInfo.isbn13)) {
      return;
    }

    try {
      // Adding to local Hive database
      _bookBox.add(book);
      await updateLastModifiedTimeHive();

      final mapData = _createMapFromSkoobBook(book);
      // Adding to Firebase - Individual book
      await _firestore
          .collection('user')
          .doc(userId)
          .collection('bookshelf')
          .doc(book.basicInfo.isbn13)
          .set(mapData);

      // Adding to Firebase - Collective list
      await _firestore
          .collection('user')
          .doc(userId)
          .collection('bookshelf')
          .doc('list')
          .set({book.basicInfo.isbn13: mapData}, SetOptions(merge: true));
      await updateLastModifiedTimeFirestore();
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
        await updateLastModifiedTimeHive();

        final mapData = _createMapFromSkoobBook(book);
        // Updating Firebase - Individual book document
        await _firestore
            .collection('user')
            .doc(userId)
            .collection('bookshelf')
            .doc(book.basicInfo.isbn13)
            .update(mapData);

        // Updating Firebase - Collective list
        await _firestore
            .collection('user')
            .doc(userId)
            .collection('bookshelf')
            .doc('list')
            .set({book.basicInfo.isbn13: mapData}, SetOptions(merge: true));
        await updateLastModifiedTimeFirestore();
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
        await updateLastModifiedTimeHive();

        // Deleting from Firebase - Individual book document
        await _firestore.collection('user').doc(userId).collection('bookshelf').doc(book.basicInfo.isbn13).delete();

        // Removing from Firebase - Collective list
        await _firestore.collection('user').doc(userId).collection('bookshelf').doc('list').update({
          book.basicInfo.isbn13: FieldValue.delete(),
        });
        await updateLastModifiedTimeFirestore();
      } catch (e) {
        print("Error deleting book from Firestore and Hive: $e");
      }
    }
  }

  Future<void> updateLastModifiedTimeHive() async {
    await _settingBox.put('lastModifiedTime', DateTime.now().toIso8601String());
    print("UserDataManger-- updating last modified time local(hive): ${DateTime.now()}");
  }

  Future<DateTime?> getLastModifiedTimeHive() async {
    String? time = _settingBox.get('lastModifiedTime');
    return time != null ? DateTime.parse(time) : null;
  }

  Future<void> updateLastModifiedTimeFirestore() async {
    try {
      await _firestore.collection('user').doc(userId).set({
        'lastModifiedTime': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      print("UserDataManger-- updating last modified time server(firestore): ${FieldValue.serverTimestamp()}");
    } catch (e) {
      print("Failed to update Firestore timestamp: $e");
    }
  }

  Future<DateTime?> getLastModifiedTimeFirestore() async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('user')
          .doc(userId)
          .get();
      if (userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Timestamp? timestamp = userData['lastModifiedTime'] as Timestamp?;
        return timestamp?.toDate();
      }
    } catch (e) {
      print("Failed to fetch Firestore timestamp: $e");
      return null;
    }
    return null;
  }

  Future<void> syncBookshelfFromLocal() async {
    try {
      List<Book> localBooks = _bookBox.values.toList();
      WriteBatch batch = _firestore.batch();
      DocumentReference listDocRef = _firestore.collection('user').doc(userId).collection('bookshelf').doc('list');
      Map<String, dynamic> listData = {};

      for (Book book in localBooks) {
        DocumentReference docRef = _firestore.collection('user').doc(userId).collection('bookshelf').doc(book.basicInfo.isbn13);
        Map<String, dynamic> bookData = {
          'title': book.basicInfo.title,
          'author': book.basicInfo.author,
          'translator': book.basicInfo.translator,
          'publisher': book.basicInfo.publisher,
          'category': book.basicInfo.category,
          'isbn13': book.basicInfo.isbn13,
          'comment': book.customInfo.comment,
          'rate': book.customInfo.rate,
          'status': book.customInfo.status.toString(),
        };
        batch.set(docRef, bookData);
        listData[book.basicInfo.isbn13] = bookData;
      }
      batch.set(listDocRef, listData, SetOptions(merge: true));

      await batch.commit();
      await updateLastModifiedTimeFirestore();

    } catch (e) {
      print("UserDataManager-- Error syncing from local to server: $e");
    }
  }

  Future<void> syncBookshelfFromServer() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('user')
          .doc(userId)
          .collection('bookshelf')
          .get();

      await _bookBox.clear();

      print("number of documents in bookshelf: ${querySnapshot.size}");
      for (var doc in querySnapshot.docs) {
        print("Document: ${doc.id}");
        print("Document: ${doc.data()}");
        print("Document: ${doc.data().runtimeType}");
        if (doc.id == "list") continue; // Skip the 'list' document
        if (doc.data() != null && doc.data() is Map<String, dynamic>) {
          Book book = Book.fromFirestore(doc.data()! as Map<String, dynamic>);
          print(book);
          await _bookBox.add(book);
        } else {
          print("Document ${doc.id} is empty or data is not accessible.");
        }
      }
      await updateLastModifiedTimeHive();
    } catch (e) {
      print("UserDataManager-- Error syncing from server to local: $e");
    }
  }
}