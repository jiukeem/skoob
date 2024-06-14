import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skoob/app/models/skoob_user.dart';
import 'package:skoob/app/services/user_service.dart';
import 'package:skoob/app/views/pages/auth/auth_start.dart';
import 'package:skoob/app/views/pages/setting/widget/password_confirm_dialog.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

import '../../../services/third_party/firebase_analytics.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/custom_text_input_formatter.dart';
import '../../widgets/skoob_alert_dialog.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = _userService.currentUser;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          _buildProfileSection(user),
          const GeneralDivider(verticalPadding: 0,),
          _buildLogoutMenu(),
          _buildDeleteAccountMenu(),
          _buildLoadingBarIfNeed(),
        ],
      ),
    );
  }

  Widget _buildProfileSection(SkoobUser? user) {
    return Column(
      children: [
        Text(
          user?.name ?? '',
          style: const TextStyle(
              fontFamily: 'LexendMedium',
              fontSize: 24.0
          ),
        ),
        const SizedBox(height: 4.0,),
        Text(
          user?.email ?? '',
          style: const TextStyle(
              fontFamily: 'NotoSansKRLight',
              fontSize: 18.0,
              color: AppColors.gray1
          ),
        ),
        const SizedBox(height: 24.0,),
      ],
    );
  }

  Widget _buildLogoutMenu() {
    return InkWell(
      onTap: () {
        AnalyticsService.logEvent('setting_button_tapped_logout');
        _showLogoutDialog(context);
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(FluentIcons.door_arrow_right_16_regular),
            SizedBox(width: 20,),
            Text(
                '로그아웃',
                style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'NotoSansKRMedium'
                )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountMenu() {
    return InkWell(
      onTap: () {
        AnalyticsService.logEvent('setting_button_tapped_delete_account');
        _showDeleteAccountDialog(context);
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(FluentIcons.person_delete_16_filled, color: AppColors.warningRed,),
            SizedBox(width: 20,),
            Text(
                '회원탈퇴',
                style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'NotoSansKRRegular',
                    color: AppColors.warningRed
                )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBarIfNeed() {
    return _isLoading
        ? const SpinKitRotatingCircle(
            size: 30.0,
            color: AppColors.primaryYellow,
          )
        : const SizedBox.shrink();
  }

  void _logout() async {
    await _userService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthStart()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final bool? shouldLogout = await buildAlertDialog(
      context: context,
      contentText: '로그아웃 하시겠습니까?',
      actions: [
        buildDialogButton(
          text: '취소',
          backgroundColor: Colors.transparent,
          textColor: AppColors.softBlack,
          onTap: () {
            Navigator.of(context).pop(false);
          },
        ),
        buildDialogButton(
          text: '로그아웃',
          backgroundColor: AppColors.primaryGreen,
          textColor: AppColors.white,
          onTap: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );

    if (mounted && shouldLogout == true) {
      AnalyticsService.logEvent('setting_start_logout');
      _logout();
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final bool? shouldDeleteAccount = await buildAlertDialog(
      context: context,
      contentText: 'SKOOB을 탈퇴하시겠습니까?\n모든 기록이 삭제됩니다',
      actions: [
        buildDialogButton(
          text: '취소',
          backgroundColor: Colors.transparent,
          textColor: AppColors.softBlack,
          onTap: () {
            Navigator.of(context).pop(false);
          },
        ),
        buildDialogButton(
          text: '진행',
          backgroundColor: AppColors.warningRed,
          textColor: AppColors.white,
          onTap: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );

    if (mounted && shouldDeleteAccount == true) {
      AnalyticsService.logEvent('setting_proceed_delete_account');
      _showPasswordConfirmDialog(context);
    }
  }

  Future<void> _showPasswordConfirmDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return PasswordConfirmDialog(
          userService: _userService,
          onConfirmed: () {
            AnalyticsService.logEvent('setting_start_delete_account');
            _deleteAccount();
          },
        );
      },
    );
  }

  void _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    await _userService.deleteAccount();
    Fluttertoast.showToast(
      msg: '계정이 안전하게 삭제되었습니다\n그동안 SKOOB을 이용해주셔서 감사합니다',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.gray1,
      textColor: AppColors.white,
      fontSize: 14.0,
    );
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => const AuthStart()),
          (Route<dynamic> route) => false,
    );
  }
}
