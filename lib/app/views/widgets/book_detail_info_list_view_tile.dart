import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/controller/shared_list_state.dart';
import 'package:skoob/app/utils/util_fuctions.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';
import 'package:skoob/app/views/widgets/status_label.dart';

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
    return InkWell(
      onTap: () {
        _showStatusOptionBottomSheet(context);
      },
      child: _buildChildBasedOnStatus(status),
    );
  }

  Future<void> _showStatusOptionBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 240,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0)
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12.0),
                Container(
                  width: 64,
                  height: 2,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: AppColors.gray2,
                  ),
                ),
                const SizedBox(height: 18.0),
                const Text(
                  'STATUS',
                  style: TextStyle(
                    fontFamily: 'LexendRegular',
                    fontSize: 16.0,
                    color: AppColors.softBlack
                  ),
                ),
                const SizedBox(height: 16.0),
                const GeneralDivider(verticalPadding: 0),
                // TODO refactor below
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          final book = widget.book;
                          book.customInfo.status = BookReadingStatus.notStarted;
                          Provider.of<SharedListState>(context, listen: false).replaceWithUpdatedBook(book);
                          Navigator.pop(context, BookReadingStatus.notStarted);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          child: StatusLabel(BookReadingStatus.notStarted),
                        ),
                      ),
                      const GeneralDivider(verticalPadding: 0),
                      InkWell(
                        onTap: () {
                          final book = widget.book;
                          book.customInfo.status = BookReadingStatus.reading;
                          Provider.of<SharedListState>(context, listen: false).replaceWithUpdatedBook(book);
                          Navigator.pop(context, BookReadingStatus.reading);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          child: StatusLabel(BookReadingStatus.reading),
                        ),
                      ),
                      const GeneralDivider(verticalPadding: 0),
                      InkWell(
                        onTap: () {
                          final book = widget.book;
                          book.customInfo.status = BookReadingStatus.done;
                          Provider.of<SharedListState>(context, listen: false).replaceWithUpdatedBook(book);
                          Navigator.pop(context, BookReadingStatus.done);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          child: StatusLabel(BookReadingStatus.done),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );

    if (result != null) {
      setState(() {
        widget.book.customInfo.status = result as BookReadingStatus;
      });
    }
  }

  Widget _buildChildBasedOnStatus(BookReadingStatus status) {
    switch (status) {
      case BookReadingStatus.initial:
        return Container(
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
        );
      case BookReadingStatus.notStarted:
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: StatusLabel(status),
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
              child: StatusLabel(status),
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
              child: StatusLabel(status),
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
        return const Text('default');
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