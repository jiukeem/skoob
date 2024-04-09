import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/shared_list_state.dart';
import '../../models/book.dart';
import '../../utils/app_colors.dart';
import '../../utils/util_fuctions.dart';
import '../widgets/general_divider.dart';

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
  File? _image;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.existingRecord);
  }

  void saveUserRecord(String record, Book book) {
    if (record.isEmpty) {
      return;
    }

    switch (widget.userRecordOption) {
      case UserRecordOption.comment:
        book.customInfo.comment = _textController.text;
      case UserRecordOption.note:
        book.customInfo.note[getCurrentDateAndTimeAsString()] = _textController.text;
      case UserRecordOption.highlight:
        book.customInfo.highlight[getCurrentDateAndTimeAsString()] = _textController.text;
      default:
        return;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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
          if (_image != null)
            Image.file(_image!),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                const GeneralDivider(verticalPadding: 0.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.userRecordOption == UserRecordOption.comment
                    ? const SizedBox.shrink()
                    : IconButton(
                        onPressed: () {
                          _pickImage();
                        },
                        icon: const Icon(FluentIcons.image_16_regular)
                    ),
                    IconButton(
                        onPressed: () {
                          saveUserRecord(_textController.text, book);
                          Provider.of<SharedListState>(context, listen: false).replaceWithUpdatedBook(book);
                          Navigator.pop(context, book);
                          },
                        icon: const Icon(FluentIcons.checkmark_16_filled)
                    )
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
