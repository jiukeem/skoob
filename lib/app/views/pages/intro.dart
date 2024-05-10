import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:skoob/app/controller/user_data_manager.dart';
import 'package:skoob/app/models/skoob_user.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/skoob.dart';
import 'package:skoob/app/views/pages/debug_error.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserDataManager _dataManager = UserDataManager();

  @override
  void initState() {
    super.initState();
  }

  void _checkAuthentication() async {
    if (_auth.currentUser != null) {
      _updateSkoobUserInfo(_auth.currentUser!, isNewUser: false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Skoob()));
      return;
    }

    try {
      User? user = await signInWithGoogle();
      if (user != null) {
        DateTime creationTime = user.metadata.creationTime!;
        DateTime lastSignInTime = user.metadata.lastSignInTime!;
        Duration diff = lastSignInTime.difference(creationTime);

        // If the duration is less than a few seconds, treat as new user
        bool isNewUser = diff < const Duration(seconds: 5);
        _updateSkoobUserInfo(user, isNewUser: isNewUser);

        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Skoob()));
      } else {
        // Handle null user scenario (e.g., user cancelled the sign-in)
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => ErrorPage(errorMessage: 'Sign-in with Google cancelled by user')));
      }
    } catch (e) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ErrorPage(errorMessage: 'Error in Intro Page:: _checkAuthentication\n$e')));
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in process
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ErrorPage(errorMessage: 'Error in Intro Page:: signInWithGoogle\n$e')));
    }
    return null;
  }

  void _updateSkoobUserInfo(User user, {required bool isNewUser}) {
    final skoobUser = _createSkoobUser(user);
    _dataManager.setUser(skoobUser);
    _dataManager.updateUserProfile(skoobUser, isNewUser).then((success) {
      if (!success) {
        print("Failed to update user data synchronously");
      }
    });
    return;
  }

  SkoobUser _createSkoobUser(User user) {
    return SkoobUser(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      photoUrl: user.photoURL ?? '',
      latestFeedBookTitle: '',
      latestFeedStatus: BookReadingStatus.initial,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
            'SKOOB',
            style: TextStyle(
              fontFamily: 'LexendExaExtraBold',
              fontSize: 48.0,
              color: AppColors.white
            ),
          ),
            ElevatedButton(onPressed: () {_checkAuthentication();}, child: Text('log in with google'))
        ]),
      ),
    );
  }
}