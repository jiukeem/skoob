import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skoob/app/views/pages/sign_in.dart';
import 'package:skoob/app/views/pages/skoob.dart';
import '../../utils/app_colors.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    await Future.wait([
      FirebaseAuth.instance.authStateChanges().first,
      Future.delayed(const Duration(milliseconds: 1000)),
    ]).then((results) {
      final user = results[0] as User?;
      if (user == null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SignIn()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Skoob()));
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Intro-- Authentication check failed: $error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/temp_logo.png', height: 160,),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
            ),
          ],
        ),
      ),
    );
  }
}