import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skoob/app/views/pages/skoob.dart';

import '../../controller/user_data_manager.dart';
import '../../utils/app_colors.dart';

class Welcome extends StatefulWidget {
  final bool isNewUser;
  final String email;
  final String password;
  final String name;

  const Welcome({required this.isNewUser, required this.email, required this.password, required this.name, super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final UserDataManager _userDataManager = UserDataManager();
  bool networkDone = false;

  @override
  void initState() {
    super.initState();
    _handleUser();
  }

  void _handleUser() async {
    if (widget.isNewUser) {
      await _userDataManager.handleSignIn(name: widget.name, email: widget.email, password: widget.password);
    } else {
      await _userDataManager.handleLogin(widget.email);
    }
    networkDone = true;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Skoob()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: const Text(
          'SKOOB',
          style: TextStyle(
              fontFamily: 'LexendExaBold',
              fontSize: 36,
              color: AppColors.primaryGreen
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100.0,),
              Text(
                '환영합니다',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'NotoSansKRBold',
                    fontSize: 24,
                    color: AppColors.softBlack,
                ),
              ),
              const SizedBox(height: 100,),
              const SpinKitRotatingCircle(
                size: 40.0,
                color: AppColors.primaryYellow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
