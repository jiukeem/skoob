import 'package:flutter/material.dart';
import 'package:skoob/app/views/pages/auth_start.dart';

import '../../controller/user_data_manager.dart';
import '../../services/firebase_analytics.dart';
import '../../utils/app_colors.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final UserDataManager _userDataManager = UserDataManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('SETTING',
          style: TextStyle(
          fontFamily: 'LexendExaRegular',
        ),),
        centerTitle: true,
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
      ),
      body: InkWell(
        onTap: () {
          _showLogoutDialog(context);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'NotoSansKRRegular'
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  void _logout() async {
    await _userDataManager.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthStart()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    Widget cancelButton = InkWell(
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        child: Text(
          '취소',
          style: TextStyle(
            fontFamily: 'NotoSansKRMedium',
            fontSize: 14.0,
            color: AppColors.softBlack,
          ),
        ),
      ),
      onTap: () {
        AnalyticsService.logEvent('Setting-- logout', parameters: {
          'result': 'cancelled'
        });
        Navigator.of(context).pop(false);
      },
    );

    Widget confirmButton = InkWell(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          color: AppColors.primaryGreen,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
          child: Text(
            '로그아웃',
            style: TextStyle(
              fontFamily: 'NotoSansKRMedium',
              fontSize: 14.0,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      onTap: () {
        AnalyticsService.logEvent('Setting-- logout', parameters: {
          'result': 'logged out'
        });
        Navigator.of(context).pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      content: const Text('로그아웃 하시겠습니까?'),
      actions: [
        cancelButton,
        confirmButton,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );

    final bool? shouldLogout = await showDialog(
        context: context,
        builder: (context) {
          return alert;
        });

    if (mounted && shouldLogout == true) {
      _logout();
    }
  }
}
