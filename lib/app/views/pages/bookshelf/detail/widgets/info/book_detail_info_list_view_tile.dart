import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/services/book_service.dart';
import 'package:skoob/app/services/third_party/firebase_analytics.dart';
import 'package:skoob/app/services/user_service.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/utils/util_fuctions.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';
import 'package:skoob/app/views/pages/bookshelf/widgets/status_label.dart';

class BookDetailInfoListViewTile extends StatefulWidget {
  final Book book;
  final int index;

  const BookDetailInfoListViewTile({super.key, required this.book, required this.index});

  @override
  State<BookDetailInfoListViewTile> createState() => _BookDetailInfoListViewTileState();
}

class _BookDetailInfoListViewTileState extends State<BookDetailInfoListViewTile> {
  final UserService _userService = UserService();
  final BookService _bookService = BookService();
  final List<String> labels = infoLabelList;

  @override
  Widget build(BuildContext context) {
    final String label = labels[widget.index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(label),
            const SizedBox(height: 4.0),
            _generateContentWidget(label),
          ],
        ),
        const GeneralDivider(verticalPadding: 16.0)
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'LexendLight',
        fontSize: 14.0,
        color: AppColors.gray1,
      ),
    );
  }

  Widget _generateContentWidget(String label) {
    switch (label) {
      case 'Status':
        return _generateStatusWidget(widget.book.customInfo.status);
      case 'Title':
        return _generateTextWidget(widget.book.basicInfo.title);
      case 'Author':
        return _generateTextWidget(widget.book.basicInfo.author);
      case 'Translator':
        return _generateTextWidget(widget.book.basicInfo.translator);
      case 'Publisher':
        return _generateTextWidget(widget.book.basicInfo.publisher);
      case 'Publish Date':
        return _generateTextWidget(widget.book.basicInfo.pubDate, fontFamily: 'InriaSansRegular', fontSize: 18.0);
      case 'Category':
        return _generateCategoryWidget(widget.book.basicInfo.category);
      case 'Link':
        return _generateTextWidget(widget.book.basicInfo.infoUrl);
      default:
        return _generateTextWidget('error');
    }
  }

  Widget _generateTextWidget(String data, {String fontFamily = 'NotoSansKRRegular', double fontSize = 16.0}) {
    return Text(
      data,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
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
            AnalyticsService.logEvent('book_detail_info_status_tapped');
            _showStatusOptionBottomSheet(context);
          },
          child: _buildChildBasedOnStatus(status),
        ),
        const GeneralDivider(verticalPadding: 16.0),
        _generateCalendarWidget(),
      ],
    );
  }

  Widget _generateCategoryWidget(String category) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        color: AppColors.gray3,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
        child: Text(
          category.split('>')[1],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.softBlack,
            fontFamily: 'NotoSansKRRegular',
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildChildBasedOnStatus(BookReadingStatus status) {
    if (status == BookReadingStatus.initial) {
      return Container(
        width: 50.0,
        height: 22.0,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
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

  Widget _generateCalendarWidget() {
    final status = widget.book.customInfo.status;
    final startReadingDate = widget.book.customInfo.startReadingDate;
    final finishReadingDate = widget.book.customInfo.finishReadingDate;

    bool startReadingDateOn = status == BookReadingStatus.reading || status == BookReadingStatus.done;
    bool finishReadingDateOn = status == BookReadingStatus.done;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateColumn('Started reading on', startReadingDate, startReadingDateOn, status),
        _buildDateColumn('Finished reading on', finishReadingDate, finishReadingDateOn, status, isFinishDate: true),
      ],
    );
  }

  Widget _buildDateColumn(String label, String date, bool dateOn, BookReadingStatus status, {bool isFinishDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 2.0),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'LexendLight',
              fontSize: 14.0,
              color: AppColors.gray1,
            ),
          ),
        ),
        InkWell(
          splashColor: dateOn ? AppColors.gray3 : Colors.transparent,
          onTap: () async {
            if (dateOn) {
              final DateTime? pickedDate = await _selectDate(context, isFinishDate: isFinishDate);
              if (pickedDate != null) {
                final newDate = dateTimeToString(pickedDate);
                AnalyticsService.logEvent('book_detail_info_${isFinishDate ? 'finish' : 'start'}_date_changed', parameters: {
                  'status': status.toString(),
                  'date_from': date,
                  'date_to': newDate
                });
                if (!isFinishDate) {
                  _checkIfNeedToResetFinishDate(pickedDate);
                }
                setState(() {
                  if (isFinishDate) {
                    widget.book.customInfo.finishReadingDate = newDate;
                  } else {
                    widget.book.customInfo.startReadingDate = newDate;
                  }
                });
                _bookService.saveBook(widget.book);
              }
            }
          },
          child: Row(
            children: [
              Text(
                date.isEmpty ? 'YYYY.MM.DD' : date,
                style: TextStyle(
                  fontFamily: 'NotoSansKRRegular',
                  fontSize: 18.0,
                  color: dateOn ? AppColors.softBlack : AppColors.gray3,
                ),
              ),
              const SizedBox(width: 4.0),
              Icon(
                FluentIcons.calendar_48_regular,
                color: dateOn ? AppColors.softBlack : AppColors.gray3,
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

  Future<DateTime?> _selectDate(BuildContext context, {bool isFinishDate = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: isFinishDate
          ? DateTime.parse(widget.book.customInfo.startReadingDate.replaceAll('.', '-'))
          : DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.softBlack,
              onPrimary: AppColors.primaryYellow,
              onSurface: AppColors.softBlack,
              onBackground: AppColors.white,
              surfaceTint: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  Future<void> _showStatusOptionBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildStatusOptionBottomSheet();
      },
    );

    if (result != null) {
      setState(() {
        widget.book.customInfo.status = result as BookReadingStatus;
      });
    }
  }

  Widget _buildStatusOptionBottomSheet() {
    return Container(
      height: 240,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
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
              color: AppColors.softBlack,
            ),
          ),
          const SizedBox(height: 16.0),
          const GeneralDivider(verticalPadding: 0),
          _buildStatusOptions(),
        ],
      ),
    );
  }

  Widget _buildStatusOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusOption(BookReadingStatus.notStarted),
          const GeneralDivider(verticalPadding: 0),
          _buildStatusOption(BookReadingStatus.reading),
          const GeneralDivider(verticalPadding: 0),
          _buildStatusOption(BookReadingStatus.done),
        ],
      ),
    );
  }

  Widget _buildStatusOption(BookReadingStatus status) {
    return InkWell(
      onTap: () {
        final book = widget.book;
        AnalyticsService.logEvent('book_detail_info_status_changed', parameters: {
          'status_from': book.customInfo.status.toString(),
          'status_to': status.toString()
        });
        book.customInfo.status = status;
        _bookService.saveBook(widget.book);
        if (status == BookReadingStatus.reading || status == BookReadingStatus.done) {
          _userService.updateLatestFeed(widget.book, status);
        }
        Navigator.pop(context, status);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: StatusLabel(status),
      ),
    );
  }
}

final List<String> infoLabelList = [
  'Status',
  'Title',
  'Author',
  'Translator',
  'Publisher',
  'Publish Date',
  'Category',
  'Link',
];