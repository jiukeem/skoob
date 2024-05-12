import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:skoob/app/controller/user_data_manager.dart';
import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/services/firebase_analytics.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/utils/util_fuctions.dart';
import 'package:skoob/app/views/pages/book_detail.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';
import 'package:skoob/app/views/widgets/status_label.dart';

class BookDetailInfoListViewTile extends StatefulWidget {
  final Book book;
  final int index;

  const BookDetailInfoListViewTile({super.key, required this.book, required this.index});

  @override
  State<BookDetailInfoListViewTile> createState() => _BookDetailInfoListViewTileState();
}

class _BookDetailInfoListViewTileState extends State<BookDetailInfoListViewTile> {
  final List<String> labels = infoLabelList;
  final UserDataManager _dataManager = UserDataManager();

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            _showStatusOptionBottomSheet(context);
          },
          child: _buildChildBasedOnStatus(status),
        ),
        const GeneralDivider(verticalPadding: 16.0),
        _generateCalendarWidget(),
      ],
    );
  }

  Widget _generateCalendarWidget() {
    final status = widget.book.customInfo.status;
    final startReadingDate = widget.book.customInfo.startReadingDate;
    final finishReadingDate = widget.book.customInfo.finishReadingDate;

    bool startReadingDateOn = status == BookReadingStatus.reading || status == BookReadingStatus.done ? true : false;
    bool finishReadingDateOn = status == BookReadingStatus.done ? true : false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 2.0),
              child: Text(
                'Started reading on',
                style: TextStyle(
                  fontFamily: 'LexendLight',
                  fontSize: 14.0,
                  color: AppColors.gray1,
                ),
              ),
            ),
            InkWell(
              splashColor: startReadingDateOn ? AppColors.gray3 : Colors.transparent,
              onTap: () async {
                if (status == BookReadingStatus.reading || status == BookReadingStatus.done) {
                  final DateTime? pickedDate = await _selectDate(context, finishDate: DateTime.now());
                  if (pickedDate != null) {
                    _checkIfNeedToResetFinishDate(pickedDate);
                    setState(() {
                      widget.book.customInfo.startReadingDate = dateTimeToString(pickedDate);
                    });
                    _dataManager.updateBook(widget.book);
                    AnalyticsService.logEvent('Detail-- startReadingOn', parameters: {
                      'status': status.toString(),
                      'dateBefore': startReadingDate,
                      'dateAfter': pickedDate
                    });
                  }
                }
              },
              child: Row(
                children: [
                  Text(
                    startReadingDate.isEmpty ? 'YYYY.MM.DD' : startReadingDate,
                    style: TextStyle(
                      fontFamily: 'NotoSansKRRegular',
                      fontSize: 18.0,
                      color: startReadingDateOn ? AppColors.softBlack : AppColors.gray3,
                    ),
                  ),
                  const SizedBox(width: 4.0,),
                  Icon(
                    FluentIcons.calendar_48_regular,
                    color: startReadingDateOn ? AppColors.softBlack : AppColors.gray3,
                  )
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 20.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 2.0),
                child: Text(
                  'Finished reading on',
                  style: TextStyle(
                    fontFamily: 'LexendLight',
                    fontSize: 14.0,
                    color: AppColors.gray1,
                  ),
                ),
              ),
              InkWell(
                splashColor: finishReadingDateOn ? AppColors.gray3 : Colors.transparent,
                onTap: () async {
                  if (status == BookReadingStatus.done) {
                    final startDate = DateTime.parse(widget.book.customInfo.startReadingDate.replaceAll('.', '-'));
                    final DateTime? pickedDate = await _selectDate(context, startDate: startDate);
                    if (pickedDate != null) {
                      setState(() {
                        widget.book.customInfo.finishReadingDate = dateTimeToString(pickedDate);
                      });
                      _dataManager.updateBook(widget.book);
                      AnalyticsService.logEvent('Detail-- finishReadingOn', parameters: {
                        'status': status.toString(),
                        'dateBefore': finishReadingDate,
                        'dateAfter': pickedDate
                      });
                    }
                  }
                },
                child: Row(
                  children: [
                    Text(
                      finishReadingDate.isEmpty ? 'YYYY.MM.DD' : finishReadingDate,
                      style: TextStyle(
                        fontFamily: 'NotoSansKRRegular',
                        fontSize: 18.0,
                        color: finishReadingDateOn ? AppColors.softBlack : AppColors.gray3,
                      ),
                    ),
                    const SizedBox(width: 4.0,),
                    Icon(
                      FluentIcons.calendar_48_regular,
                      color: finishReadingDateOn ? AppColors.softBlack : AppColors.gray3,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _checkIfNeedToResetFinishDate(DateTime startDate) {
    if (widget.book.customInfo.finishReadingDate.isEmpty) return;

    final finishDate = DateTime.parse(widget.book.customInfo.finishReadingDate.replaceAll('.', '-'));
    if (finishDate.isBefore(startDate)) {
      widget.book.customInfo.finishReadingDate = '';
    }
  }

  Future<DateTime?> _selectDate(BuildContext context, {DateTime? startDate, DateTime? finishDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: startDate?? DateTime(2000),
      lastDate: finishDate ?? DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, Widget? child) {
        return Theme(data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.softBlack,
            onPrimary: AppColors.primaryYellow,
            onSurface: AppColors.softBlack,
            onBackground: AppColors.white,
            surfaceTint: AppColors.white
          )
        ), child: child!);
      },
    );
    return picked;
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
                          _dataManager.updateBook(widget.book);
                          Navigator.pop(context, BookReadingStatus.notStarted);
                          AnalyticsService.logEvent('Detail-- status', parameters: {
                            'statusBefore': book.customInfo.status.toString(),
                            'statusAfter': BookReadingStatus.notStarted
                          });
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
                          _dataManager.updateBook(widget.book);
                          _dataManager.updateLatestFeed(widget.book, BookReadingStatus.reading);
                          Navigator.pop(context, BookReadingStatus.reading);
                          AnalyticsService.logEvent('Detail-- status', parameters: {
                            'statusBefore': book.customInfo.status.toString(),
                            'statusAfter': BookReadingStatus.reading
                          });
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
                          _dataManager.updateBook(widget.book);
                          _dataManager.updateLatestFeed(widget.book, BookReadingStatus.done);
                          Navigator.pop(context, BookReadingStatus.done);
                          AnalyticsService.logEvent('Detail-- status', parameters: {
                            'statusBefore': book.customInfo.status.toString(),
                            'statusAfter': BookReadingStatus.done
                          });
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
    if (status == BookReadingStatus.initial) {
      return Container(
        width: 50.0,
        height: 22.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          border: Border.all(
            color: AppColors.gray2,
          ),
        ),
        child: const Icon(
          FluentIcons.add_16_regular,
          color: AppColors.gray2,
          size: 16.0,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: StatusLabel(status),
      );
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
    final String label = labels[widget.index];

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