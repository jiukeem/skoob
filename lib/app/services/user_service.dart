import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../models/book.dart';
import '../models/book/custom_info.dart';
import '../models/skoob_user.dart';
import '../repositories/firestore_repository.dart';
import '../repositories/hive_repository.dart';
import '../utils/util_fuctions.dart';
import 'third_party/firebase_function_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();
  // code above is for singleton object

  final HiveRepository _hiveManager = HiveRepository();
  final FirestoreRepository _firestoreManager = FirestoreRepository();

  SkoobUser? get currentUser => _hiveManager.getUser();
  String get userEmail => currentUser?.email ?? '';

  Future<void> init() async {
    await _hiveManager.openBox();
  }

  Future<void> dispose() async {
    await _hiveManager.dispose();
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
    if (isDocumentDataValid(userDoc)) {
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
    if (isDocumentDataValid(doc)) {
      return doc!.data() as Map<String, dynamic>;
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_getEntireUserInfo::Entire user list document is null or has no data');
      return null;
    }
  }

  SkoobUser? getCurrentLocalUser() {
    return _hiveManager.getUser();
  }

  Future<String?> getValidPassword(String email) async {
    final userDoc = await _firestoreManager.getUserProfile(email);

    if (isDocumentDataValid(userDoc)) {
      final user = userDoc!.data() as Map<String, dynamic>;
      return user['password'];
    } else {
      FirebaseCrashlytics.instance.log('UserDataMdata:anager_getValidPassword:: document is null or has no data: $email');
      return null;
    }
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

  Future<SkoobUser?> searchUserByName(String friendName) async {
    final userListMap = await getEntireUserInfo();
    if (userListMap == null || !userListMap.keys.contains(friendName)) return null;

    final friendEmail = userListMap[friendName];
    DocumentSnapshot? friendDoc = await _firestoreManager.getUserProfile(friendEmail);

    if (isDocumentDataValid(friendDoc)) {
      Map<String, dynamic> userData = friendDoc!.data() as Map<String, dynamic>;
      return SkoobUser.fromMap(userData);
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_searchUserByName::document is null or has no data: $friendEmail');
      return null;
    }
  }

  Future<List<String>> getCurrentFriendsList() async {
    DocumentSnapshot? userDoc = await _firestoreManager.getFriendList(userEmail);
    if (isDocumentDataValid(userDoc)) {
      final friendDoc = userDoc!.data() as Map<String, dynamic>;
      return friendDoc.keys.toList();
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_getCurrentFriendsList::document is null or has no data');
      return [];
    }
  }

  Future<SkoobUser?> getFriendData(String email) async {
    DocumentSnapshot? userDoc = await _firestoreManager.getUserProfile(email);

    if (isDocumentDataValid(userDoc)) {
      final friendProfile = userDoc!.data() as Map<String, dynamic>;
      return SkoobUser.fromMap(friendProfile);
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_getFriendData::document is null or has no data: $email');
      return null;
    }
  }

  Future<void> addFriend(SkoobUser friend) async {
    String userMessageToken = '';
    String friendMessageToken = '';

    DocumentSnapshot? userDoc = await _firestoreManager.getUserProfile(userEmail);
    DocumentSnapshot? friendDoc = await _firestoreManager.getUserProfile(friend.email);

    if (isDocumentDataValid(userDoc)) {
      final data = userDoc!.data() as Map<String, dynamic>;
      userMessageToken = data['messageToken'];
    } else {
      FirebaseCrashlytics.instance.log('UserDataManager_addFriend::document is null or has no data: $userEmail');
    }

    if (isDocumentDataValid(friendDoc)) {
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
}