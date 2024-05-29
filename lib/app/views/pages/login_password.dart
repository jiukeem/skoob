import 'package:flutter/material.dart';
import 'package:skoob/app/views/pages/welcome.dart';

import '../../controller/user_data_manager.dart';
import '../../utils/app_colors.dart';
import '../../utils/custom_text_input_formatter.dart';

class LoginPassword extends StatefulWidget {
  final _email;

  const LoginPassword(this._email, {super.key});

  @override
  State<LoginPassword> createState() => _LoginPasswordState();
}

class _LoginPasswordState extends State<LoginPassword> {
  final UserDataManager _userDataManager = UserDataManager();
  late TextEditingController _controller;
  String? _errorText;
  String? _validPassword;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _getValidPassword();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getValidPassword() async {
    _validPassword ??= await _userDataManager.getValidPassword(widget._email);
  }

  void _handleSubmit() {
    setState(() {
      _errorText = null;

      final password = _controller.text;
      if (_validPassword == password) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => Welcome(isNewUser: false, email: widget._email, password: password, name: '')));
      } else {
        _errorText = '비밀번호가 일치하지 않습니다';
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '비밀번호를 입력해주세요',
                    style: TextStyle(
                        fontFamily: 'NotoSansKRBold',
                        fontSize: 24,
                        color: AppColors.softBlack
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      obscureText: true,
                      controller: _controller,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        errorText: _errorText,
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
                        // errorText: _passwordErrorText
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
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 4, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                          '시작하기',
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