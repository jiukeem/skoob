import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../utils/app_colors.dart';

class BookDetailNoteListViewTile extends StatefulWidget {
  final MapEntry note;

  const BookDetailNoteListViewTile({super.key, required this.note});

  @override
  State<BookDetailNoteListViewTile> createState() => _BookDetailNoteListViewTileState();
}

class _BookDetailNoteListViewTileState extends State<BookDetailNoteListViewTile> {
  @override
  Widget build(BuildContext context) {
    final String date = widget.note.key.toString().substring(0, 16);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
                fontFamily: 'NotoSansKRRegular',
                fontSize: 13.0,
                color: AppColors.gray1
            ),
          ),
          const SizedBox(height: 4.0,),
          Text(
            widget.note.value,
            style: const TextStyle(
                fontFamily: 'NotoSansKRRegular',
                fontSize: 14.0,
                color: AppColors.softBlack
            ),
          ),
          const SizedBox(height: 16.0,)
        ],
      ),
    );
  }
}
