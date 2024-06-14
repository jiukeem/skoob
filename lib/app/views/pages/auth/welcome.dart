import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skoob/app/services/third_party/firebase_analytics.dart';
import 'package:skoob/app/services/user_service.dart';
import 'package:skoob/app/views/pages/home/skoob.dart';

import '../../../utils/app_colors.dart';

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
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _handleUser();
  }

  void _handleUser() async {
    if (widget.isNewUser) {
      await _userService.handleSignIn(name: widget.name, email: widget.email, password: widget.password);
    } else {
      await _userService.handleLogin(widget.email);
    }
    _navigateToSkoobPage();
  }

  void _navigateToSkoobPage() {
    AnalyticsService.logEvent('welcome_move_on_to_skoob_page');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Skoob()),
          (Route<dynamic> route) => false,
    );
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
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 100.0,),
              Text(
                '환영합니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'NotoSansKRBold',
                    fontSize: 24,
                    color: AppColors.softBlack,
                ),
              ),
              SizedBox(height: 100,),
              SpinKitRotatingCircle(
                size: 30.0,
                color: AppColors.primaryYellow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
