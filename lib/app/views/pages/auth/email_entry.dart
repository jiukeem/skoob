import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skoob/app/services/user_service.dart';
import 'package:skoob/app/views/pages/auth/login_password.dart';
import 'package:skoob/app/views/pages/auth/setup_password.dart';

import '../../../services/third_party/firebase_analytics.dart';
import '../../../utils/app_colors.dart';

class EmailEntry extends StatefulWidget {
  const EmailEntry({super.key});

  @override
  State<EmailEntry> createState() => _EmailEntryState();
}

class _EmailEntryState extends State<EmailEntry> {
  final UserService _userService = UserService();
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
    AnalyticsService.logEvent('email_entry_email_submitted');
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
    final emailToNameMap = await _userService.getEntireUserInfo();
    if (emailToNameMap == null) {
      AnalyticsService.logEvent('email_entry_no_network_error');
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
    final userEmailList = emailToNameMap.values;
    final userNameList = emailToNameMap.keys.toList();

    if (userEmailList.contains(_email)) {
      AnalyticsService.logEvent('email_entry_handle_existing_user');
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginPassword(_email)));
    } else {
      AnalyticsService.logEvent('email_entry_handle_new_user');
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
                      onSubmitted: (_) => _handleSubmit(),
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
