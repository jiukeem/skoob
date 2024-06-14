import 'package:flutter/material.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/utils/custom_text_input_formatter.dart';
import 'package:skoob/app/services/user_service.dart';

class PasswordConfirmDialog extends StatefulWidget {
  final UserService userService;
  final VoidCallback onConfirmed;

  const PasswordConfirmDialog({Key? key, required this.userService, required this.onConfirmed}) : super(key: key);

  @override
  _PasswordConfirmDialogState createState() => _PasswordConfirmDialogState();
}

class _PasswordConfirmDialogState extends State<PasswordConfirmDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
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
                controller: _controller,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  errorText: _errorText,
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
                final validPassword = await widget.userService.getValidPassword(widget.userService.userEmail);
                setDialogState(() {
                  _errorText = null;
                  if (validPassword == _controller.text) {
                    Navigator.pop(context, true);
                    widget.onConfirmed();
                  } else {
                    _errorText = '비밀번호가 일치하지 않습니다';
                  }
                });
              },
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        );
      },
    );
  }
}