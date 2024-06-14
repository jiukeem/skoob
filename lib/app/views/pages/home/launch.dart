import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skoob/app/services/third_party/firebase_analytics.dart';
import 'package:skoob/app/services/user_service.dart';
import 'package:skoob/app/views/pages/auth/auth_start.dart';
import 'package:skoob/app/views/pages/home/skoob.dart';

import '../../../utils/app_colors.dart';
import '../../widgets/skoob_alert_dialog.dart';

class Launch extends StatefulWidget {
  const Launch({super.key});

  @override
  State<Launch> createState() => _LaunchState();
}

class _LaunchState extends State<Launch> {
  final UserService _userService = UserService();
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkNetworkAndLogin();
  }

  void _checkNetworkAndLogin() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNoNetworkDialog(context);
      AnalyticsService.logEvent('launch_no_network_and_show_dialog');
    } else {
      _checkExistingUserCredential();
    }
  }

  void _checkExistingUserCredential() async {
    if (await _userService.isLocalUserExist()) {
      AnalyticsService.logEvent('launch_existing_user');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Skoob()));
    } else {
      AnalyticsService.logEvent('launch_new_user_and_start_sign_up');
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

  void _showNoNetworkDialog(BuildContext context) {
    buildAlertDialog(
      context: context,
      titleText: '네트워크 없음',
      contentText: '네트워크 연결 후\nSKOOB 앱을 다시 실행해주세요',
      actions: [
        buildDialogButton(
          text: '확인',
          backgroundColor: AppColors.primaryGreen,
          textColor: AppColors.white,
          onTap: () {
            Navigator.of(context).pop();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ],
      barrierDismissible: false,
    );
  }
}
