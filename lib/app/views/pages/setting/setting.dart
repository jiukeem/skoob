import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skoob/app/views/pages/auth/auth_start.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

import '../../../controller/user_data_manager.dart';
import '../../../services/firebase_analytics.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/custom_text_input_formatter.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final UserDataManager _userDataManager = UserDataManager();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = _userDataManager.currentUser;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
      ),
      body: Column(
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
          const GeneralDivider(verticalPadding: 0,),
          InkWell(
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
          ),
          InkWell(
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
          ),
          _isLoading
          ? const SpinKitRotatingCircle(
            size: 30.0,
            color: AppColors.primaryYellow,
          )
          : const SizedBox.shrink()
        ],
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
      AnalyticsService.logEvent('setting_start_logout');
      _logout();
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
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
        Navigator.of(context).pop(false);
      },
    );

    Widget confirmButton = InkWell(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          color: AppColors.warningRed,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
          child: Text(
            '진행',
            style: TextStyle(
              fontFamily: 'NotoSansKRMedium',
              fontSize: 14.0,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      content: const Text('SKOOB을 탈퇴하시겠습니까?\n모든 기록이 삭제됩니다'),
      actions: [
        cancelButton,
        confirmButton,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );

    final bool? shouldDeleteAccount = await showDialog(
        context: context,
        builder: (context) {
          return alert;
        });

    if (mounted && shouldDeleteAccount == true) {
      AnalyticsService.logEvent('setting_proceed_delete_account');
      _showPasswordConfirmDialog(context);
    }
  }

  Future<void> _showPasswordConfirmDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    String? errorText;

    final bool? shouldDeleteAccount = await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: AppColors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('확인을 위해 비밀번호를 입력해주세요'),
                  ),
                  TextField(
                    obscureText: true,
                    controller: controller,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      errorText: errorText,
                      labelText: '비밀번호',
                      labelStyle: const TextStyle(
                          color: AppColors.gray1,
                          fontFamily: 'NotoSansKRRegular'
                      ),
                      floatingLabelStyle: const TextStyle(
                          color: AppColors.softBlack,
                          fontFamily: 'NotoSansKRRegular'
                      ),
                      contentPadding: const EdgeInsets.only(bottom: 0),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.softBlack, width: 1.2),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.softBlack, width: 1.2),
                      ),
                    ),
                    inputFormatters: [
                      CustomTextInputFormatter(
                          pattern: r"""^[\w\d!@#$%^&*()_+=[\]{}|\\:;"'<>,.?/-~]+$"""
                      ),
                    ],
                    style: const TextStyle(
                      color: AppColors.softBlack,
                      fontSize: 24.0,
                    ),
                  ),
                ],
              ),
              actions: [
                InkWell(
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
                    Navigator.of(context).pop(false);
                  },
                ),
                InkWell(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: AppColors.warningRed,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                      child: Text(
                        '회원탈퇴',
                        style: TextStyle(
                          fontFamily: 'NotoSansKRMedium',
                          fontSize: 14.0,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  onTap: () async {
                    final validPassword = await _userDataManager.getValidPassword(_userDataManager.userEmail ?? '');
                    setDialogState(() {
                      errorText = null;

                      if (validPassword == controller.text) {
                        Navigator.pop(context, true);
                      } else {
                        errorText = '비밀번호가 일치하지 않습니다';
                      }
                    });
                  },
                ),
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            );
          });
        });

    if (mounted && shouldDeleteAccount == true) {
      AnalyticsService.logEvent('setting_start_delete_account');
      _deleteAccount();
    }
  }

  void _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    await _userDataManager.deleteAccount();
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
