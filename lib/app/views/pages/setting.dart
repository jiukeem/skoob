import 'package:flutter/material.dart';
import 'package:skoob/app/views/pages/launch.dart';

import '../../controller/user_data_manager.dart';
import '../../utils/app_colors.dart';
import 'intro_deprecated.dart';

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
          _logout();
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
      MaterialPageRoute(builder: (context) => const Launch()),
          (Route<dynamic> route) => false,
    );
  }
}
