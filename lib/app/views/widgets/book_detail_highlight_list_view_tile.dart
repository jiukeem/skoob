import 'package:flutter/material.dart';

import '../../models/book.dart';
import '../../utils/app_colors.dart';

class BookDetailHighlightListViewTile extends StatefulWidget {
  final Book book;

  const BookDetailHighlightListViewTile({super.key, required this.book});

  @override
  State<BookDetailHighlightListViewTile> createState() => _BookDetailHighlightListViewTileState();
}

class _BookDetailHighlightListViewTileState extends State<BookDetailHighlightListViewTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2024.02.13 09:30',
            style: TextStyle(
              fontFamily: 'NotoSansKRRegular',
              fontSize: 12.0,
              color: AppColors.gray1
            ),
          ),
          SizedBox(height: 4.0,),
          Text(
            '국민의 모든 자유와 권리는 국가안전보장·질서유지 또는 공공복리를 위하여 필요한 경우에 한하여 법률로써 제한할 수 있으며, 제한하는 경우에도 자유와 권리의 본질적인 내용을 침해할 수 없다. 국민의 모든 자유와 권리는 국가안전보장·질서유지 또는 공공복리를 위하여 필요한 경우에 한하여 법률로써 제한할 수 있으며, 제한하는 경우에도 자유와 권리의 본질적인 내용을 침해할 수 없다.',
            style: TextStyle(
                fontFamily: 'NotoSansKRRegular',
                fontSize: 13.0,
                color: AppColors.softBlack
            ),
          ),
        ],
      ),
    );
  }
}
