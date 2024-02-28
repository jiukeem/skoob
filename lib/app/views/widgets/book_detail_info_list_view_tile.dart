import 'package:flutter/material.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

import '../../models/book.dart';
import '../../utils/app_colors.dart';

class BookDetailInfoListViewTile extends StatefulWidget {
  final Book book;
  final int index;

  const BookDetailInfoListViewTile({super.key, required this.book, required this.index});

  @override
  State<BookDetailInfoListViewTile> createState() => _BookDetailInfoListViewTileState();
}

class _BookDetailInfoListViewTileState extends State<BookDetailInfoListViewTile> {
  final List<String> labelList = [
    'Status',
    'Started reading on',
    'Title',
    'Author',
    'Translator',
    'Publisher',
    'Publish Date',
    'Category',
    'Link'
  ];

  @override
  Widget build(BuildContext context) {
    final String label = labelList[widget.index];
    final String key = label.toLowerCase();
    final Map<String, dynamic> valueMap = widget.book.basicInfo.toJson();


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'LexendLight',
                  fontSize: 14.0,
                  color: AppColors.gray1,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                valueMap[key] ?? 'no result',
                style: const TextStyle(
                  fontFamily: 'NotoSansKRRegular',
                  fontSize: 16.0,
                  color: AppColors.softBlack,
                ),
              ),
            ],
          ),
        ),
        const GeneralDivider(padding: 16.0)
      ],
    );
  }
}
