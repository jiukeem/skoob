import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:skoob/app/managers/firestore_manager.dart';
import 'package:skoob/app/managers/hive_manager.dart';
import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/models/skoob_user.dart';
import 'package:skoob/app/services/firebase_function_service.dart';
import 'package:skoob/app//utils/util_fuctions.dart';

class UserDataManager {
  static final UserDataManager _instance = UserDataManager._internal();
  factory UserDataManager() => _instance;
  UserDataManager._internal();
  // code above is for singleton object

  final HiveManager _hiveManager = HiveManager();
  final FirestoreManager _firestoreManager = FirestoreManager();

  SkoobUser? get currentUser {
    return _hiveManager.getUser();
  }
  String? get userEmail => currentUser?.email;

  Future<void> initBox() async {
    _hiveManager.openBox();
  }

  void setUserFromCurrentLocalUser() async {
    final SkoobUser? user = _hiveManager.getUser();
    if (user == null) {
      return;
    }
  }

  Future<void> handleSignIn(
      {required String name, required String email, required String password}) async {

    String token = await _firestoreManager.getToken();
    final userDataMap = {
      'name': name,
      'email': email,
      'password': password,
      'messageToken': token,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      _firestoreManager.createUserCollection(email);
      _firestoreManager.updateUserProfile(userDataMap, email);
      _firestoreManager.addUserToWholeUserList(name: name, email: email);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }

    SkoobUser newUser = SkoobUser.fromMap(userDataMap);
    _hiveManager.setUser(newUser);
  }

  Future<void> handleLogin(String email) async {
    try {
      _updateLoginTime(email);
      _setLocalUserFromServer(email);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  Future<void> _updateLoginTime(String email) async {
    _firestoreManager.updateLoginTime(email);
  }

  Future<void> _setLocalUserFromServer(String email) async {
    final DocumentSnapshot userDoc = await _firestoreManager.getUserProfile(email);
    if (userDoc.data() != null) {
      _hiveManager.setUser(SkoobUser.fromMap(userDoc.data as Map<String, dynamic>));
    } else {
      // TODO handle error
    }
  }

  Future<bool> hasUser() async {
    return await _hiveManager.hasUser();
  }

  Future<Map<String, dynamic>?> getEntireUserInfo() async {
    try {
      DocumentSnapshot doc = await _firestoreManager.getEntireUserInfo();
      if (doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return null;
    }
    return null;
  }

  SkoobUser? getCurrentLocalUser() {
    return _hiveManager.getUser();
  }

  void dispose() {
    _hiveManager.dispose();
  }

  Future<String?> getValidPassword(String email) async {
    try {
      final userDoc = await _firestoreManager.getUserProfile(email);

      if (userDoc.data() != null) {
        final user = userDoc.data() as Map<String, dynamic>;
        return user['password'];
      }
      return null;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return null;
    }
  }

  Future<void> saveBook(Book book) async {
    if (await _hiveManager.isBookExist(book.basicInfo.isbn13)) {
      return;
    }

    try {
      _saveBookInHive(book);
      _saveBookInFirestore(book);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  void _saveBookInHive(Book book) {
    _hiveManager.addBook(book);
    updateLastModifiedTimeInHive();
  }

  void _saveBookInFirestore(Book book) {
    final mapData = createMapFromSkoobBook(book);
    final String isbn13 = book.basicInfo.isbn13;
    _firestoreManager.saveBook(bookData: mapData, email: userEmail ?? '', isbn13: isbn13);
    updateLastModifiedTimeInFirestore();
  }

  Future<void> deleteBook(Book book) async {
    try {
      _deleteBookInHive(book);
      _deleteBookInFirestore(book);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  void _deleteBookInHive(Book book) {
    _hiveManager.deleteBook(book);
    updateLastModifiedTimeInHive();
  }

  void _deleteBookInFirestore(Book book) {
    _firestoreManager.deleteBook(book, userEmail ?? '');
    updateLastModifiedTimeInFirestore();
  }

  Future<void> updateLatestFeed(Book book, BookReadingStatus status) async {
    if (status == BookReadingStatus.initial || status == BookReadingStatus.notStarted) {
      return;
    }

    final title = book.basicInfo.title;

    try {
      _updateLatestFeedInHive(title, status);
      _updateLatestFeedInFirestore(title, status);
      await _requestPushMessage(title, status);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  void _updateLatestFeedInHive(String title, BookReadingStatus status) {
    SkoobUser? userToUpdate = currentUser;
    if (userToUpdate != null) {
      userToUpdate.latestFeedBookTitle = title;
      userToUpdate.latestFeedStatus = status;

      _hiveManager.setUser(userToUpdate);
    } else {
      //TODO handle error
    }
  }

  void _updateLatestFeedInFirestore(String title, BookReadingStatus status) {
    final dataMap = {
      'latestFeedBookTitle': title,
      'latestFeedStatus': status.toString()
    };
    _firestoreManager.updateUserProfile(dataMap, userEmail ?? '');
  }

  Future<void> _requestPushMessage(String title, BookReadingStatus status) async {
    FirebaseFunctionService.sendStatusUpdatePushMessage(userEmail ?? '', currentUser?.name ?? '', title, status.toString());
  }


  Future<void> updateLastModifiedTimeInHive() async {
    _hiveManager.updateLastModifiedTimeInHive();
  }

  Future<DateTime?> getLastModifiedTimeInHive() async {
    String? time = _hiveManager.getLastModifiedTimeInHive();
    return time != null ? DateTime.parse(time) : null;
  }

  Future<void> updateLastModifiedTimeInFirestore() async {
    try {
      _firestoreManager.updateUserProfile({'lastModifiedAt': DateTime.now().toIso8601String()}, userEmail ?? '');
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  Future<DateTime?> getLastModifiedTimeInFirestore() async {
    try {
      DocumentSnapshot userDoc = await _firestoreManager.getUserProfile(userEmail ?? '');
      if (userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? time = userData['lastModifiedAt'] as String?;
        return time != null ? DateTime.parse(time) : null;
      } else {
        //TODO handle error
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return null;
    }
    return null;
  }

  Future<void> syncBookshelfFromLocal() async {
    try {
      Map<String, Book> localBooks = _hiveManager.getBookshelf();
      await _firestoreManager.updateBookshelf(localBooks, userEmail ?? '');
      updateLastModifiedTimeInFirestore();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  Future<void> syncBookshelfFromServer() async {
    try {
      QuerySnapshot querySnapshot = await _firestoreManager.getBookshelf(userEmail ?? '');

      List<Book> bookList = [];
      for (var doc in querySnapshot.docs) {
        if (doc.id == "list") continue; // Skip the 'list' document
        if (doc.data() != null && doc.data() is Map<String, dynamic>) {
          Book book = Book.fromFirestore(doc.data()! as Map<String, dynamic>);
          bookList.add(book);
        } else {
          //TODO handle error
        }
      }
      _hiveManager.updateBookshelf(bookList);
      await updateLastModifiedTimeInHive();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  Future<SkoobUser?> searchUserByName(String friendName) async {
    try {
      DocumentSnapshot entireUserInfo = await _firestoreManager.getEntireUserInfo();
      Map<String, dynamic> userListData = entireUserInfo.data() as Map<String, dynamic>;

      if (!userListData.keys.contains(friendName)) {
        return null;
      }

      final friendEmail = userListData[friendName];
      DocumentSnapshot? friendDoc = await _firestoreManager.getUserProfile(friendEmail);

      if (friendDoc.data() != null) {
        Map<String, dynamic> userData = friendDoc.data() as Map<String, dynamic>;
        return SkoobUser.fromMap(userData);
      } else {
        return null;
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return null;
    }
  }

  Future<List<String>> getCurrentFriendsList() async {
    try {
      DocumentSnapshot? userDoc = await _firestoreManager.getFriendList(userEmail ?? '');
      if (userDoc.data() == null) return [];

      final friendDoc = userDoc.data() as Map<String, dynamic>;
      return friendDoc.keys.toList();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return [];
    }
  }

  Future<SkoobUser?> getFriendData(String email) async {
    try {
      DocumentSnapshot? userDoc = await _firestoreManager.getUserProfile(email);

      if (userDoc.data() == null) return null;

      final friendProfile = userDoc.data() as Map<String, dynamic>;
      return SkoobUser.fromMap(friendProfile);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return null;
    }
  }

  Future<List<Book>> getFriendBookshelf(String email) async {
    try {
      DocumentSnapshot doc = await _firestoreManager.getBookshelfBrief(email);

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
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return [];
    }
  }
  
  Future<void> addFriend(SkoobUser friend) async {
    String? userMessageToken;
    String? friendMessageToken;

    try {
      DocumentSnapshot userDoc = await _firestoreManager.getUserProfile(userEmail ?? '');
      DocumentSnapshot friendDoc = await _firestoreManager.getUserProfile(friend.email);

      if (userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        userMessageToken = data['messageToken'];
      }

      if (friendDoc.data() != null) {
        final data = friendDoc.data() as Map<String, dynamic>;
        friendMessageToken = data['messageToken'];
      }

      final myData = {userEmail ?? '': {'messageToken': userMessageToken}};
      final friendData = {friend.email: {'messageToken': friendMessageToken}};

      _firestoreManager.addFriend(myEmail: userEmail ?? '', friendData: friendData);
      _firestoreManager.addFriend(myEmail: friend.email, friendData: myData);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  Future<void> logout() async {
    await _hiveManager.clearAllLocalData();
  }

  Future<void> deleteAccount() async {
    await _deleteServerData();
    await _deleteLocalData();
    return;
  }

  Future<void> _deleteServerData() async {
    await _firestoreManager.deleteUserDocumentAndSubCollection(userEmail ?? '');
    await _firestoreManager.deleteUserInUsersList(currentUser?.name ?? '');
  }

  Future<void> _deleteLocalData() async {
    await _hiveManager.clearAllLocalData();
  }
}