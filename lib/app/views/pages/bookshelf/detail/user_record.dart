import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/services/book_service.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

import '../../../../services/third_party/firebase_analytics.dart';
import '../../../widgets/skoob_alert_dialog.dart';

class UserRecord extends StatefulWidget {
  final Book book;
  final String existingRecord;
  final UserRecordOption userRecordOption;

  const UserRecord({super.key, required this.book, required this.existingRecord, required this.userRecordOption});

  @override
  State<UserRecord> createState() => _UserRecordPageState();
}

class _UserRecordPageState extends State<UserRecord> {
  final BookService _bookService = BookService();
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
        break;
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
        return _handleBackButton(book);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(book),
        body: Column(
          children: [
            _buildTextField(),
            _buildBottomActions(book),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(Book book) {
    return AppBar(
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
    );
  }

  Widget _buildTextField() {
    return Expanded(
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
          style: const TextStyle(fontSize: 14.0),
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
  }

  Widget _buildBottomActions(Book book) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const GeneralDivider(verticalPadding: 0.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  _handleSubmit(book);
                },
                icon: const Icon(FluentIcons.checkmark_16_filled),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _handleBackButton(Book book) async {
    if (book.customInfo.comment != _textController.text) {
      AnalyticsService.logEvent('user_record_back_button_tapped', parameters: {
        'text_changed': true,
      });
      _showSaveDialog(context, book);
    } else {
      AnalyticsService.logEvent('user_record_back_button_tapped', parameters: {
        'text_changed': false,
      });
    }
    return true;
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
    final bool? shouldSaveComment = await buildAlertDialog(
      context: context,
      contentText: '변경사항을 저장할까요?',
      actions: [
        buildDialogButton(
          text: '저장하지 않고 나가기',
          backgroundColor: Colors.transparent,
          textColor: AppColors.softBlack,
          onTap: () {
            AnalyticsService.logEvent('user_record_dialog_do_not_save');
            Navigator.of(context).pop(false);
          },
        ),
        buildDialogButton(
          text: '저장',
          backgroundColor: AppColors.primaryGreen,
          textColor: AppColors.white,
          onTap: () {
            AnalyticsService.logEvent('user_record_dialog_save');
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );

    if (mounted && shouldSaveComment == true) {
      _handleSubmit(book);
    } else if (mounted && shouldSaveComment == false) {
      Navigator.pop(context);
    }
  }
}

enum UserRecordOption {comment, note, highlight}
