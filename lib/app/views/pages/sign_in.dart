import 'package:flutter/material.dart';
import 'package:skoob/app/views/pages/bookshelf.dart';
import 'package:skoob/app/views/pages/skoob.dart';

import '../../services/sign_in_with_google.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'welcome to sign in page!'
            ),
            ElevatedButton(
              onPressed: () {
                signInWithGoogle().then((result) {
                  if (result.user != null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => Skoob()));
                  }
                }).catchError((error) {
                  print("Login Failed: $error");
                });
              },
              child: Text("Sign in with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
