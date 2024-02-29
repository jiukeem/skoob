import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../utils/app_colors.dart';

class UserRecord extends StatefulWidget {
  final Book book;

  const UserRecord({super.key, required this.book});

  @override
  State<UserRecord> createState() => _UserRecordPageState();
}

class _UserRecordPageState extends State<UserRecord> {
  @override
  Widget build(BuildContext context) {
    final Book book = widget.book;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Column(
          children: [
            Text(
                book.basicInfo.title,
              style: TextStyle(
                fontFamily: 'NotoSansKRMedium',
                fontSize: 16.0,
                color: AppColors.softBlack,
              ),
            ),
            SizedBox(height: 4.0,),
            Text(
              'comment',
              style: TextStyle(
                fontFamily: 'LexendLight',
                fontSize: 18.0,
                color: AppColors.gray2
              ),
            ),
          ],
        ),
      ),
      body: Center(child: Text('user record'),),
    );
  }
}
