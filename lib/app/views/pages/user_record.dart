import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

import '../../controller/shared_list_state.dart';
import '../../models/book.dart';
import '../../utils/app_colors.dart';

class UserRecord extends StatefulWidget {
  final Book book;
  final String existingComment;

  const UserRecord({super.key, required this.book, required this.existingComment});

  @override
  State<UserRecord> createState() => _UserRecordPageState();
}

class _UserRecordPageState extends State<UserRecord> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.existingComment);
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                cursorWidth: 1.2,
                autofocus: true,
                style: TextStyle(
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
                GeneralDivider(verticalPadding: 0.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: () {
                      book.customInfo.comment = _textController.text;
                      Provider.of<SharedListState>(context, listen: false).replaceWithUpdatedBook(book);
                      Navigator.pop(context, _textController.text);
                    }, icon: Icon(FluentIcons.checkmark_16_filled))
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
