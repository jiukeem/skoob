import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/skoob.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    final user = _auth.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Skoob()));
    } else {
      await signInWithGoogle();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _saveUserInfoToFirestore(user);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Skoob()));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
    }
  }

  Future<void> _saveUserInfoToFirestore(User user) async {
    Map<String, dynamic> userData = {
      'uid': user.uid,
      'createdAt': DateTime.now().toIso8601String(),
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'phoneNumber': user.phoneNumber ?? '',
    };

    await _firestore
        .collection('user')
        .doc(user.uid)
        .collection('profile')
        .doc('info')
        .set(userData, SetOptions(merge: true));
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