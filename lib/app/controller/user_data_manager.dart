import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/models/skoob_user.dart';

class UserDataManager {
  static final UserDataManager _instance = UserDataManager._internal();
  factory UserDataManager() => _instance;
  UserDataManager._internal();
  // code above is for singleton object

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  SkoobUser? getCurrentLocalUser() {
    return _userBox.getAt(0);
  }

  void dispose() {
    _bookBox.close();
    _userBox.close();
  }

  Future<bool> updateUserProfile(Map<String, String> user, bool isNewUser) async {
    try {
      var userDocument = _firestore
          .collection('user')
          .doc(user['uid'])
          .collection('profile')
          .doc('info');

      Map<String, dynamic> dataToUpdate = {
        if (!isNewUser)
          'lastLoggedInAt': DateTime.now().toIso8601String()
        else
          'createdAt': DateTime.now().toIso8601String(),
        ...user,
      };
      await userDocument.set(dataToUpdate, SetOptions(merge: true));

      if (isNewUser) {
        _firestore.collection('user').doc('list').set({user['email']!: user['uid']}, SetOptions(merge: true));
      }
    } catch (e) {
      print("Failed to update Firestore or Hive: $e");
      return false;
    }

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('user')
          .doc(user['uid'])
          .collection('profile')
          .doc('info')
          .get();

      if (userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        SkoobUser skoobUser = SkoobUser.fromMap(data);

        await _userBox.put(user['uid'], skoobUser);
        setUser(skoobUser);
      }
    } catch (e) {
      print("Failed to update Firestore or Hive: $e");
      return false;
    }
    return true;
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

  Future<void> updateLatestFeed(Book book, BookReadingStatus status) async {
    if (status == BookReadingStatus.initial || status == BookReadingStatus.notStarted) {
      return;
    }

    final title = book.basicInfo.title;
    SkoobUser? user = _userBox.get(userId);
    if (user == null) {
      return;
    }
    user.latestFeedBookTitle = title;
    user.latestFeedStatus = status;
    _userBox.put(userId, user);
    setUser(user);

    try {
      await _firestore
          .collection('user')
          .doc(userId)
          .collection('profile')
          .doc('info')
          .set({
        'latestFeedBookTitle': title,
        'latestFeedStatus': status.toString(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Failed to update Firestore latestFeed: $e");
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
        final bookData = _createMapFromSkoobBook(book);
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
        if (doc.id == "list") continue; // Skip the 'list' document
        if (doc.data() != null && doc.data() is Map<String, dynamic>) {
          Book book = Book.fromFirestore(doc.data()! as Map<String, dynamic>);
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

  Future<SkoobUser?> searchUserByEmail(String email) async {
    String? userId;
    try {
      DocumentSnapshot userList = await _firestore
          .collection('user')
          .doc('list')
          .get();

      Map<String, dynamic> userListData = userList.data() as Map<String, dynamic>;

      userListData.forEach((key, value) {
        print('key: $key, value: $value');
        if (key == email) {
          userId = value;
          print('found userId: $userId');
        }
      });
      print('userID: $userId');
    } catch (e) {
      print("Failed to fetch searchUserByEmail--1: $e");
      return null;
    }

    if (userId == null) return null;

    try {
      DocumentSnapshot? user = await _firestore
          .collection('user')
          .doc(userId)
          .collection('profile')
          .doc('info')
          .get();

      print('user.data(): ${user.data()}');
      if (user.data() != null) {
        Map<String, dynamic> userData = user.data() as Map<String, dynamic>;
        print('userData: $userData');
        print('skoobuser: ${SkoobUser.fromMap(userData)}');
        return SkoobUser.fromMap(userData);
      }
      return null;
    } catch (e) {
      print("Failed to fetch searchUserByEmail--2: $e");
      return null;
    }
  }

  Future<List<String>> getCurrentFriendsList() async {
    try {
      DocumentSnapshot? userDoc = await _firestore
          .collection('user')
          .doc(userId)
          .collection('friend')
          .doc('list')
          .get();

      if (userDoc.data() == null) return [];

      final friendDoc = userDoc.data() as Map<String, dynamic>;
      return List<String>.from(friendDoc['friendsList']);
    } catch (e) {
      print("UserDataManager-- failed to getCurrentFriendsList: $e");
      return [];
    }
  }

  Future<SkoobUser?> getFriendData(String uid) async {
    try {
      DocumentSnapshot? userDoc = await _firestore
          .collection('user')
          .doc(uid)
          .collection('profile')
          .doc('info')
          .get();

      if (userDoc.data() == null) return null;

      final friendProfile = userDoc.data() as Map<String, dynamic>;
      return SkoobUser.fromMap(friendProfile);
    } catch (e) {
      print("UserDataManager-- failed to getFriendData: $e");
      return null;
    }
  }

  Future<List<Book>> getFriendBookshelf(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('user')
          .doc(uid)
          .collection('bookshelf')
          .doc('list')
          .get();

      List<Book> bookList = [];
      if (doc.data() != null && doc.data() is Map<String, dynamic>) {
        final map = doc.data() as Map<String, dynamic>;
        final books = map.values;
        for (final value in books) {
          Book book = Book.fromFirestore(value as Map<String ,dynamic>);
          bookList.add(book);
        }
      }
      return bookList;
    } catch (e) {
      return [];
    }
  }
  
  Future<void> addFriend(SkoobUser user) async {
    final newFriendUid = user.uid;

    DocumentReference documentReference = _firestore
        .collection('user')
        .doc(userId)
        .collection('friend')
        .doc('list');

    documentReference.set({
      'friendsList': FieldValue.arrayUnion([newFriendUid])
    }, SetOptions(merge: true)).then((_) {
      print('Friend added successfully');
    }).catchError((error) {
      print('Error adding friend: $error');
    });
  }

  void logout() {
    _bookBox.clear();
    _userBox.clear();
    _settingBox.clear();
  }
}