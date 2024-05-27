import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skoob/app/views/pages/login_password.dart';
import 'package:skoob/app/views/pages/setup_password.dart';
import 'package:skoob/app/views/pages/auth_start.dart';

import '../../controller/user_data_manager.dart';
import '../../utils/app_colors.dart';

class EmailEntry extends StatefulWidget {
  const EmailEntry({super.key});

  @override
  State<EmailEntry> createState() => _EmailEntryState();
}

class _EmailEntryState extends State<EmailEntry> {
  final UserDataManager _userDataManager = UserDataManager();
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorMessage;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    _email = _controller.text;

    if (_checkValidity()) {
      setState(() {
        _errorMessage = null;
      });
      _navigateEmailCorrespondingPage();
    } else {
      _showInvalidFormatError();
    }
  }

  bool _checkValidity() {
    RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );
    return emailRegExp.hasMatch(_email);
  }

  void _showInvalidFormatError() {
    setState(() {
      _errorMessage = '올바른 이메일 형식이 아닙니다';
    });
  }

  Future<void> _navigateEmailCorrespondingPage() async {
    final emailToNameMap = await _userDataManager.getAllUserMap();
    if (emailToNameMap == null) {
      Fluttertoast.showToast(
        msg: '네트워크 연결을 확인해주세요',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.gray1,
        textColor: AppColors.white,
        fontSize: 14.0,
      );
      return;
    }
    final userEmailList = emailToNameMap.keys;
    final userNameList = emailToNameMap.values.map((value) => value as String).toList();

    if (userEmailList.contains(_email)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginPassword(_email)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SetupPassword(_email, userNameList)));
    }
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
                    '이메일을 입력해주세요',
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
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: ' example@email.com',
                        hintStyle: const TextStyle(
                          color: AppColors.gray2,
                          fontSize: 24.0
                        ),
                        contentPadding: const EdgeInsets.only(bottom: 0),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.softBlack, width: 1.6),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.softBlack, width: 1.6),
                        ),
                        errorText: _errorMessage
                      ),
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
