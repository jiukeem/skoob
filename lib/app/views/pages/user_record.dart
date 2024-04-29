import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

import '../../controller/user_data_manager.dart';
import '../../models/book.dart';
import '../../utils/app_colors.dart';

class UserRecord extends StatefulWidget {
  final Book book;
  final String existingRecord;
  final UserRecordOption userRecordOption;

  const UserRecord({super.key, required this.book, required this.existingRecord, required this.userRecordOption});

  @override
  State<UserRecord> createState() => _UserRecordPageState();
}

class _UserRecordPageState extends State<UserRecord> {
  late TextEditingController _textController;
  final UserDataManager _dataManager = UserDataManager();

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

    return Scaffold(
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
                      saveUserRecord(_textController.text, book);
                      _dataManager.updateBook(book);
                      Navigator.pop(context, book);
                    }, icon: const Icon(FluentIcons.checkmark_16_filled))
                  ],
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

enum UserRecordOption {comment, note, highlight}
