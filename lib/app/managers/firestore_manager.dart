import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:skoob/app/utils/util_fuctions.dart';

import '../models/book.dart';

class FirestoreManager {
  static final FirestoreManager _instance = FirestoreManager._internal();
  factory FirestoreManager() => _instance;
  FirestoreManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String> getToken() async {
    return await _firebaseMessaging.getToken() ?? '';
  }

  Future<void> createUserCollection(String email) async {
    _firestore.collection('user').doc(email).set({});
  }

  Future<void> updateUserProfile(Map<String, dynamic> userDataMap, String email) async {
    _firestore
        .collection('user')
        .doc(email)
        .collection('profile')
        .doc('info')
        .set(userDataMap, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUserProfile(String email) async {
    return await _firestore
        .collection('user')
        .doc(email)
        .collection('profile')
        .doc('info')
        .get();
  }

  Future<void> addUserToWholeUserList({required String name, required String email}) async {
    _firestore
        .collection('user')
        .doc('list')
        .set({name: email}, SetOptions(merge: true));
  }

  Future<void> updateLoginTime(email) async {
    _firestore
        .collection('user')
        .doc(email)
        .collection('profile')
        .doc('info')
        .set({'lastLoggedInAt': DateTime.now().toIso8601String()}, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getEntireUserInfo() async {
    return await _firestore
        .collection('user')
        .doc('list')
        .get();
  }

  Future<void> saveBook(
      {required Map<String, String> bookData, required String email, required String isbn13}) async {
    await _firestore
        .collection('user')
        .doc(email)
        .collection('bookshelf')
        .doc(isbn13)
        .set(bookData);

    await _firestore
        .collection('user')
        .doc(email)
        .collection('bookshelf')
        .doc('list')
        .set({isbn13: bookData}, SetOptions(merge: true));
  }

  Future<void> deleteBook(Book book, String email) async {
    await _firestore
        .collection('user')
        .doc(email)
        .collection('bookshelf')
        .doc(book.basicInfo.isbn13)
        .delete();

    await _firestore
        .collection('user')
        .doc(email)
        .collection('bookshelf')
        .doc('list')
        .update({
          book.basicInfo.isbn13: FieldValue.delete(),
        });
  }

  Future<void> updateBookshelf(Map<String, Book> booksToUpdate, String email) async {
    await _firestore
        .collection('user')
        .doc(email)
        .collection('bookshelf')
        .doc('list')
        .set(booksToUpdate, SetOptions(merge: true));

    for (String isbn13 in booksToUpdate.keys) {
      final bookData = createMapFromSkoobBook(booksToUpdate[isbn13]!);
      await _firestore
          .collection('user')
          .doc(email)
          .collection('bookshelf')
          .doc(isbn13)
          .set(bookData, SetOptions(merge: true));
    }
  }

  Future<QuerySnapshot> getBookshelf(String email) async {
    return await _firestore
        .collection('user')
        .doc(email)
        .collection('bookshelf')
        .get();
  }

  Future<DocumentSnapshot> getBookshelfBrief(String email) async {
    return await _firestore
        .collection('user')
        .doc(email)
        .collection('bookshelf')
        .doc('list')
        .get();
  }

  Future<DocumentSnapshot> getFriendList(String email) async {
    return await _firestore
        .collection('user')
        .doc(email)
        .collection('friend')
        .doc('list')
        .get();
  }

  Future<void> addFriend({
      required String myEmail,
      required Map<String, dynamic> friendData}) async {

    return await _firestore
        .collection('user')
        .doc(myEmail)
        .collection('friend')
        .doc('list')
        .set(friendData, SetOptions(merge: true));
  }

  Future<void> deleteUserDocumentAndSubCollection(String email) async {
    DocumentReference docRef = _firestore.collection('user').doc(email);

    List<String> subCollections = ['profile', 'friend', 'bookshelf'];
    for (String subColName in subCollections) {
      CollectionReference subColRef = docRef.collection(subColName);
      QuerySnapshot snapshot = await subColRef.get();

      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }

    // Once all subcollections are cleared, delete the main document
    await docRef.delete();
  }

  Future<void> deleteUserInUsersList(String name) async {
    await _firestore
        .collection('user')
        .doc('list')
        .update({name: FieldValue.delete()});
  }
}