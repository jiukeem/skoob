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

  SkoobUser? get currentUser => _hiveManager.getUser();
  String get userEmail => currentUser?.email ?? '';

  Future<void> initBox() async {
    _hiveManager.openBox();
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

    await Future.wait([
    _firestoreManager.createUserCollection(email),
    _firestoreManager.updateUserProfile(userDataMap, email),
    _firestoreManager.addUserToWholeUserList(name: name, email: email),
    _hiveManager.setUser(SkoobUser.fromMap(userDataMap))
    ]);
  }

  Future<void> handleLogin(String email) async {
    await Future.wait([
    _updateLoginTime(email),
    _setLocalUserFromServer(email)
    ]);
  }

  Future<void> _updateLoginTime(String email) async {
    _firestoreManager.updateLoginTime(email);
  }

  Future<void> _setLocalUserFromServer(String email) async {
    final DocumentSnapshot? userDoc = await _firestoreManager.getUserProfile(email);
    if (_isDocumentDataValid(userDoc)) {
      _hiveManager.setUser(SkoobUser.fromMap(userDoc!.data as Map<String, dynamic>));
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_setLocalUserFromServer::User document is null or has no data: $email');
    }
  }

  Future<bool> isLocalUserExist() async {
    return await _hiveManager.hasUser();
  }

  Future<Map<String, dynamic>?> getEntireUserInfo() async {
    DocumentSnapshot? doc = await _firestoreManager.getEntireUserInfo();
    if (_isDocumentDataValid(doc)) {
      return doc!.data() as Map<String, dynamic>;
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_getEntireUserInfo::Entire user list document is null or has no data');
      return null;
    }
  }

  SkoobUser? getCurrentLocalUser() {
    return _hiveManager.getUser();
  }

  void dispose() {
    _hiveManager.dispose();
  }

  Future<String?> getValidPassword(String email) async {
    final userDoc = await _firestoreManager.getUserProfile(email);

    if (_isDocumentDataValid(userDoc)) {
      final user = userDoc!.data() as Map<String, dynamic>;
      return user['password'];
    } else {
      FirebaseCrashlytics.instance.log('UserDataMdata:anager_getValidPassword:: document is null or has no data: $email');
      return null;
    }
  }

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

  Future<void> updateLatestFeed(Book book, BookReadingStatus status) async {
    if (status == BookReadingStatus.initial || status == BookReadingStatus.notStarted) {
      return;
    }

    final title = book.basicInfo.title;

    await Future.wait([
      _updateLatestFeedInHive(title, status),
      _updateLatestFeedInFirestore(title, status),
      _requestPushMessage(title, status)
    ]);
  }

  Future<void> _updateLatestFeedInHive(String title, BookReadingStatus status) async {
    SkoobUser? userToUpdate = currentUser;
    if (userToUpdate != null) {
      userToUpdate.latestFeedBookTitle = title;
      userToUpdate.latestFeedStatus = status;

      await _hiveManager.setUser(userToUpdate);
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_updateLatestFeedInHive::currentUser is null');
    }
  }

  Future<void> _updateLatestFeedInFirestore(String title, BookReadingStatus status) async {
    final dataMap = {
      'latestFeedBookTitle': title,
      'latestFeedStatus': status.toString()
    };
    await _firestoreManager.updateUserProfile(dataMap, userEmail);
  }

  Future<void> _requestPushMessage(String title, BookReadingStatus status) async {
    await FirebaseFunctionService.sendStatusUpdatePushMessage(userEmail, currentUser?.name ?? '', title, status.toString());
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
    if (_isDocumentDataValid(doc)) {
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

  Future<SkoobUser?> searchUserByName(String friendName) async {
    final userListMap = await getEntireUserInfo();
    if (userListMap == null || !userListMap.keys.contains(friendName)) return null;

    final friendEmail = userListMap[friendName];
    DocumentSnapshot? friendDoc = await _firestoreManager.getUserProfile(friendEmail);

    if (_isDocumentDataValid(friendDoc)) {
      Map<String, dynamic> userData = friendDoc!.data() as Map<String, dynamic>;
      return SkoobUser.fromMap(userData);
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_searchUserByName::document is null or has no data: $friendEmail');
      return null;
    }
  }

  Future<List<String>> getCurrentFriendsList() async {
    DocumentSnapshot? userDoc = await _firestoreManager.getFriendList(userEmail);
    if (_isDocumentDataValid(userDoc)) {
      final friendDoc = userDoc!.data() as Map<String, dynamic>;
      return friendDoc.keys.toList();
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_getCurrentFriendsList::document is null or has no data');
      return [];
    }
  }

  Future<SkoobUser?> getFriendData(String email) async {
    DocumentSnapshot? userDoc = await _firestoreManager.getUserProfile(email);

    if (_isDocumentDataValid(userDoc)) {
      final friendProfile = userDoc!.data() as Map<String, dynamic>;
      return SkoobUser.fromMap(friendProfile);
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_getFriendData::document is null or has no data: $email');
      return null;
    }
  }

  Future<List<Book>> getFriendBookshelf(String email) async {
    DocumentSnapshot? doc = await _firestoreManager.getBookshelfBrief(email);

    List<Book> bookList = [];
    if (_isDocumentDataValid(doc)) {
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
  
  Future<void> addFriend(SkoobUser friend) async {
    String userMessageToken = '';
    String friendMessageToken = '';

    DocumentSnapshot? userDoc = await _firestoreManager.getUserProfile(userEmail);
    DocumentSnapshot? friendDoc = await _firestoreManager.getUserProfile(friend.email);

    if (_isDocumentDataValid(userDoc)) {
      final data = userDoc!.data() as Map<String, dynamic>;
      userMessageToken = data['messageToken'];
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_addFriend::document is null or has no data: $userEmail');
    }

    if (_isDocumentDataValid(friendDoc)) {
      final data = friendDoc!.data() as Map<String, dynamic>;
      friendMessageToken = data['messageToken'];
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_addFriend::document is null or has no data: ${friend.email}');
    }

    final myData = {userEmail: {'messageToken': userMessageToken}};
    final friendData = {friend.email: {'messageToken': friendMessageToken}};

    await Future.wait([
      _firestoreManager.addFriend(myEmail: userEmail, friendData: friendData),
      _firestoreManager.addFriend(myEmail: friend.email, friendData: myData)
    ]);
  }

  Future<void> logout() async {
    await _hiveManager.clearAllLocalData();
  }

  Future<void> deleteAccount() async {
    await Future.wait([
      _deleteLocalData(),
      _deleteServerData()
    ]);
  }

  Future<void> _deleteServerData() async {
    await Future.wait([
      _firestoreManager.deleteUserDocumentAndSubCollection(userEmail),
      _firestoreManager.deleteUserInUsersList(currentUser?.name ?? '')
    ]);
  }

  Future<void> _deleteLocalData() async {
    await _hiveManager.clearAllLocalData();
  }

  bool _isDocumentDataValid(DocumentSnapshot? doc) {
    return doc != null && doc.data() != null;
  }
}