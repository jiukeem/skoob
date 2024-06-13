import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/services/book_service.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

import '../../../../services/third_party/firebase_analytics.dart';

class UserRecord extends StatefulWidget {
  final Book book;
  final String existingRecord;
  final UserRecordOption userRecordOption;

  const UserRecord({super.key, required this.book, required this.existingRecord, required this.userRecordOption});

  @override
  State<UserRecord> createState() => _UserRecordPageState();
}

class _UserRecordPageState extends State<UserRecord> {
  BookService _bookService = BookService();
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.existingRecord);
  }

  void saveUserRecord(String record, Book book) {
    switch (widget.userRecordOption) {
      case UserRecordOption.comment:
        book.customInfo.comment = _textController.text;
      case UserRecordOption.note:
        // book.customInfo.note[getCurrentDateAndTimeAsString()] = _textController.text;
      case UserRecordOption.highlight:
        // book.customInfo.highlight[getCurrentDateAndTimeAsString()] = _textController.text;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Book book = widget.book;

    return WillPopScope(
      onWillPop: () async {
        if (book.customInfo.comment != _textController.text) {
          AnalyticsService.logEvent('user_record_back_button_tapped', parameters: {
            'text_changed': true
          });
          _showSaveDialog(context, book);
        }
        AnalyticsService.logEvent('user_record_back_button_tapped', parameters: {
          'text_changed': false
        });
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          centerTitle: true,
          title: Text(
              book.basicInfo.title,
            style: const TextStyle(
              fontFamily: 'NotoSansKRMedium',
              fontSize: 16.0,
              color: AppColors.softBlack,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  cursorWidth: 1.2,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 14.0
                  ),
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const GeneralDivider(verticalPadding: 0.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(onPressed: () {
                        _handleSubmit(book);
                      }, icon: const Icon(FluentIcons.checkmark_16_filled))
                    ],
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmit(Book book) {
    AnalyticsService.logEvent('user_record_save_comment', parameters: {
      'comment_from': book.customInfo.comment,
      'comment_to': _textController.text
    });
    saveUserRecord(_textController.text, book);
    _bookService.saveBook(book);
    Navigator.pop(context, book);
  }

  Future<void> _showSaveDialog(BuildContext context, Book book) async {
    Widget cancelButton = InkWell(
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        child: Text(
          '저장하지 않고 나가기',
          style: TextStyle(
            fontFamily: 'NotoSansKRMedium',
            fontSize: 14.0,
            color: AppColors.softBlack,
          ),
        ),
      ),
      onTap: () {
        AnalyticsService.logEvent('user_record_dialog_do_not_save');
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
            '저장',
            style: TextStyle(
              fontFamily: 'NotoSansKRMedium',
              fontSize: 14.0,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      onTap: () {
        AnalyticsService.logEvent('user_record_dialog_save');
        Navigator.of(context).pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      content: const Text('변경사항을 저장할까요?'),
      actions: [
        cancelButton,
        confirmButton,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );

    final bool? shouldSaveComment = await showDialog(
        context: context,
        builder: (context) {
          return alert;
        });

    if (mounted && shouldSaveComment == true) {
      _handleSubmit(book);
    }

    if (mounted && shouldSaveComment == false) {
      Navigator.pop(context);
    }
  }
}

enum UserRecordOption {comment, note, highlight}
