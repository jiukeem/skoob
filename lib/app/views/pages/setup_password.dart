import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skoob/app/views/pages/setup_name.dart';

import '../../utils/app_colors.dart';
import '../../utils/custom_text_input_formatter.dart';

class SetupPassword extends StatefulWidget {
  final String email;
  final List<String> nameList;

  const SetupPassword(this.email, this.nameList, {super.key});

  @override
  State<SetupPassword> createState() => _SetupPasswordState();
}

class _SetupPasswordState extends State<SetupPassword> {
  late TextEditingController _controller;
  late TextEditingController _confirmController;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() {
      _passwordErrorText = null;
      _confirmPasswordErrorText = null;

      final password = _controller.text;
      final confirmPassword = _confirmController.text;
      if (password.length < 6 || password.length > 20) {
        _passwordErrorText = '비밀번호는 6-20자 사이여야 합니다';
      } else if (password != confirmPassword) {
        _confirmPasswordErrorText = '비밀번호가 일치하지 않습니다';
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                SetupName(nameList: widget.nameList, email: widget.email, password: password,)));
      }
    });
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100.0,),
              const Text(
                '스쿱에 오신 걸 환영해요!\n비밀번호를 설정해주세요',
                style: TextStyle(
                    fontFamily: 'NotoSansKRBold',
                    fontSize: 24,
                    color: AppColors.softBlack
                ),
              ),
              const SizedBox(height: 32.0,),
              TextField(
                obscureText: true,
                controller: _controller,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                    labelText: '비밀번호(6-20자)',
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
                      borderSide: BorderSide(color: AppColors.softBlack, width: 1.6),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.softBlack, width: 1.6),
                    ),
                  errorText: _passwordErrorText
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
              const SizedBox(height: 32,),
              TextField(
                obscureText: true,
                controller: _confirmController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                    labelText: '비밀번호 확인',
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
                      borderSide: BorderSide(color: AppColors.softBlack, width: 1.6),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.softBlack, width: 1.6),
                    ),
                  errorText: _confirmPasswordErrorText
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
                onSubmitted: (_) => _handleSubmit(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 28, 4, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            foregroundColor: AppColors.softBlack,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: AppColors.gray1,
                              width: 1.0
                            ),
                            borderRadius: BorderRadius.circular(40.0),
                          )
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text(
                          '뒤로',
                          style: TextStyle(
                              fontFamily: 'NotoSansKRRegular',
                              fontSize: 18,
                              color: AppColors.gray1
                          ),
                        )),
                    TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            foregroundColor: AppColors.softBlack
                        ),
                        onPressed: () {
                          _handleSubmit();
                        },
                        child: const Text(
                          '확인',
                          style: TextStyle(
                              fontFamily: 'NotoSansKRBold',
                              fontSize: 18,
                              color: AppColors.white
                          ),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


