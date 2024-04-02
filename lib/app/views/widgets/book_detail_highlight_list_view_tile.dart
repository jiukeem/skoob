import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../utils/app_colors.dart';

class BookDetailHighlightListViewTile extends StatefulWidget {
  final MapEntry highlight;

  const BookDetailHighlightListViewTile({super.key, required this.highlight});

  @override
  State<BookDetailHighlightListViewTile> createState() => _BookDetailHighlightListViewTileState();
}

class _BookDetailHighlightListViewTileState extends State<BookDetailHighlightListViewTile> {
  @override
  Widget build(BuildContext context) {
    final String date = widget.highlight.key.toString().substring(0, 16);
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
            widget.highlight.value,
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
