import 'package:flutter/material.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

import '../../models/book.dart';
import '../../models/book/custom_info.dart';
import '../../utils/app_colors.dart';

class BookDetailInfoListViewTile extends StatefulWidget {
  final Book book;
  final int index;

  const BookDetailInfoListViewTile({super.key, required this.book, required this.index});

  @override
  State<BookDetailInfoListViewTile> createState() => _BookDetailInfoListViewTileState();
}

class _BookDetailInfoListViewTileState extends State<BookDetailInfoListViewTile> {
  final List<String>labels = [
    'Status',
    'Title',
    'Author',
    'Translator',
    'Publisher',
    'Publish Date',
    'Category',
    'Link',
  ];

  Widget _generateTextWidget(String data) {
    return Text(
      data,
      style: const TextStyle(
        fontFamily: 'NotoSansKRRegular',
        fontSize: 16.0,
        color: AppColors.softBlack,
      ),
    );
  }

  Widget _generateStatusWidget(BookReadingStatus status) {
    switch (status) {
      case BookReadingStatus.initial:
        return Text('initial');
      case BookReadingStatus.notStarted:
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.gray2,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
            child: Text(
              'not started',
              style: TextStyle(
                  fontFamily: 'LexendRegular',
                  color: AppColors.white,
                  fontSize: 14.0),
            ),
          ),
        );
      case BookReadingStatus.reading:
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryYellow,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
            child: Text(
              'reading',
              style: TextStyle(
                  fontFamily: 'LexendRegular',
                  color: AppColors.softBlack,
                  fontSize: 14.0),
            ),
          ),
        );
      case BookReadingStatus.done:
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.softBlack,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
            child: Text(
              'done',
              style: TextStyle(
                  fontFamily: 'LexendRegular',
                  color: AppColors.white,
                  fontSize: 14.0),
            ),
          ),
        );
      default:
        return Text('default');
    }
  }

  Widget _generateContentWidget(String label) {
    switch (label) {
      case 'Status':
        // final BookReadingStatus status = widget.book.customInfo.status;
        return _generateStatusWidget(BookReadingStatus.reading);
      case 'Title':
        return _generateTextWidget(widget.book.basicInfo.title);
      case 'Author':
        return _generateTextWidget(widget.book.basicInfo.author);
      case 'Translator':
        return _generateTextWidget(widget.book.basicInfo.translator);
      case 'Publisher':
        return _generateTextWidget(widget.book.basicInfo.publisher);
      case 'Publish Date':
        return _generateTextWidget(widget.book.basicInfo.pubDate.toString().replaceAll('-', '.'));
      case 'Category':
        return _generateTextWidget(widget.book.basicInfo.category);
      case 'Link':
        return _generateTextWidget(widget.book.basicInfo.infoUrl);
      default:
        return _generateTextWidget('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = labels[widget.index];

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
              _generateContentWidget(label),
            ],
          ),
        ),
        const GeneralDivider(padding: 16.0)
      ],
    );
  }
}