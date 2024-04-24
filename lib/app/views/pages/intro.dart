import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/skoob.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../controller/user_data_manager.dart';
import '../../models/skoob_user.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  void _checkAuthentication() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _updateSkoobUserInfo(user, false);
    } else {
      user = await signInWithGoogle();
      if (user != null) {
        _updateSkoobUserInfo(user, true);
      }
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Skoob()));
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      return user;
    } catch (e) {
        print('Error signing in with Google: $e');
    }
    return null;
  }

  void _updateSkoobUserInfo(User user, bool isNewUser) {
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
      photoUrl: user.photoURL ?? ''
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Text(
          'SKOOB',
          style: TextStyle(
            fontFamily: 'LexendExaExtraBold',
            fontSize: 48.0,
            color: AppColors.white
          ),
        ),
      ),
    );
  }
}