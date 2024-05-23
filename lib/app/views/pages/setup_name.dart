import 'package:flutter/material.dart';
import 'package:skoob/app/views/pages/welcome.dart';

import '../../utils/app_colors.dart';
import '../../utils/custom_text_input_formatter.dart';

class SetupName extends StatefulWidget {
  final List<String> nameList;
  final String email;
  final String password;

  const SetupName({required this.nameList, required this.email, required this.password, super.key});

  @override
  State<SetupName> createState() => _SetupNameState();
}

class _SetupNameState extends State<SetupName> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() {
      _errorText = null;
      final name = _controller.text;
      if (widget.nameList.contains(name)) {
        _errorText = '이미 존재하는 이름입니다';
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => Welcome(
                  email: widget.email,
                  password: widget.password,
                  name: name,
                  isNewUser: true,
                )));
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
                    '사용할 이름을 정해주세요',
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
                      controller: _controller,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          labelText: '이름',
                          helperText: '영문 4-16자',
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
                            pattern: r"""w\d"""
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
