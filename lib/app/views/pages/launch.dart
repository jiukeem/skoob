import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skoob/app/views/pages/auth_start.dart';
import 'package:skoob/app/views/pages/skoob.dart';

import '../../controller/user_data_manager.dart';
import '../../utils/app_colors.dart';

class Launch extends StatefulWidget {
  const Launch({super.key});

  @override
  State<Launch> createState() => _LaunchState();
}

class _LaunchState extends State<Launch> {
  final UserDataManager _userDataManager = UserDataManager();

  @override
  void initState() {
    super.initState();
    _checkExistingUserCredential();
  }

  void _checkExistingUserCredential() async {
    if (await _userDataManager.hasUser()) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Skoob()));
      _userDataManager.setUserFromCurrentLocalUser();
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthStart()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
          color: AppColors.white,
          child: const Center(
            child: SpinKitRotatingCircle(
              size: 30.0,
              color: AppColors.primaryYellow,
            ),
          ),
        )
    );
  }
}
