import 'package:connectivity/connectivity.dart';
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
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkNetworkAndLogin();
  }

  void _checkNetworkAndLogin() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      _checkExistingUserCredential();
    }
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

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('네트워크 없음'),
          content: const Text("네트워크 연결 후 앱을 다시 실행해주세요"),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
