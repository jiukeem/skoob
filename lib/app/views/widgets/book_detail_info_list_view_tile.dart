import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:skoob/app/utils/util_fuctions.dart';
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
        return InkWell(
          onTap: () {},
          child: Container(
            width: 50.0,
            height: 22.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              border: Border.all(
                color: AppColors.gray2,
              ),
            ),
            child: Icon(
                FluentIcons.add_16_regular,
                color: AppColors.gray2,
              size: 16.0,
            ),
          ),
        );
      case BookReadingStatus.notStarted:
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
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
          ),
        );
      case BookReadingStatus.reading:
        String startReadingDate = widget.book.customInfo.startReadingDate;
        if (startReadingDate.isEmpty) {
          startReadingDate = getCurrentDateAsString();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 2.0, 0, 8.0),
              child: Container(
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
              ),
            ),
            const GeneralDivider(verticalPadding: 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 2.0),
              child: const Text(
                'Started reading on',
                style: TextStyle(
                  fontFamily: 'LexendLight',
                  fontSize: 14.0,
                  color: AppColors.gray1,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  startReadingDate,
                  style: const TextStyle(
                    fontFamily: 'InriaSansRegular',
                    fontSize: 18.0,
                    color: AppColors.softBlack,
                  ),
                ),
                const SizedBox(width: 4.0,),
                const Icon(FluentIcons.calendar_16_regular)
              ],
            ),
          ],
        );
      case BookReadingStatus.done:
        String startReadingDate = widget.book.customInfo.startReadingDate;
        if (startReadingDate.isEmpty) {
          startReadingDate = getCurrentDateAsString();
        }
        String finishedReadingDate = widget.book.customInfo.startReadingDate;
        if (finishedReadingDate.isEmpty) {
          finishedReadingDate = getCurrentDateAsString();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 2.0, 0, 8.0),
              child: Container(
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
              ),
            ),
            const GeneralDivider(verticalPadding: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 2.0),
                      child: const Text(
                        'Started reading on',
                        style: TextStyle(
                          fontFamily: 'LexendLight',
                          fontSize: 14.0,
                          color: AppColors.gray1,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          startReadingDate,
                          style: const TextStyle(
                            fontFamily: 'InriaSansRegular',
                            fontSize: 18.0,
                            color: AppColors.softBlack,
                          ),
                        ),
                        const SizedBox(width: 4.0,),
                        const Icon(FluentIcons.calendar_16_regular)
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 2.0),
                      child: const Text(
                        'Finished reading on',
                        style: TextStyle(
                          fontFamily: 'LexendLight',
                          fontSize: 14.0,
                          color: AppColors.gray1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 40.0, 0),
                      child: Row(
                        children: [
                          Text(
                            startReadingDate,
                            style: const TextStyle(
                              fontFamily: 'InriaSansRegular',
                              fontSize: 18.0,
                              color: AppColors.softBlack,
                            ),
                          ),
                          const SizedBox(width: 4.0,),
                          const Icon(FluentIcons.calendar_16_regular)
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

          ],
        );
      default:
        return Text('default');
    }
  }

  Widget _generateContentWidget(String label) {
    switch (label) {
      case 'Status':
        final BookReadingStatus status = widget.book.customInfo.status;
        return _generateStatusWidget(status);
      case 'Title':
        return _generateTextWidget(widget.book.basicInfo.title);
      case 'Author':
        return _generateTextWidget(widget.book.basicInfo.author);
      case 'Translator':
        return _generateTextWidget(widget.book.basicInfo.translator);
      case 'Publisher':
        return _generateTextWidget(widget.book.basicInfo.publisher);
      case 'Publish Date':
        return Text(
          widget.book.basicInfo.pubDate,
          style: const TextStyle(
            fontFamily: 'InriaSansRegular',
            fontSize: 18.0,
            color: AppColors.softBlack,
          ),
        );
      case 'Category':
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            color: AppColors.gray3,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Text(
              widget.book.basicInfo.category.split('>')[1],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.softBlack,
                  fontFamily: 'NotoSansKRRegular',
                  fontSize: 16.0),
            ),
          ),
        );
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
        Column(
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
        const GeneralDivider(verticalPadding: 16.0)
      ],
    );
  }
}