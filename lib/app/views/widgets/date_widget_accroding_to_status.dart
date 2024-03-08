import 'package:skoob/app/models/book/custom_info.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

Widget dateWidgetAccordingToStatus(double fontSize, BookReadingStatus status, {required String startDate, required String finishDate}) {
  final s = startDate.length > 2 ? startDate.substring(2) : '';
  final f = finishDate.length > 2 ? finishDate.substring(2) : '';

  switch (status) {
    case BookReadingStatus.initial:
      return const SizedBox.shrink();
    case BookReadingStatus.notStarted:
      return const SizedBox.shrink();
    case BookReadingStatus.reading:
      if (startDate.isEmpty) {
        return const SizedBox.shrink();
      } else {
        return Text(
          '$s ~ $f',
          style: TextStyle(
              fontFamily: 'InriaSansRegular',
              color: AppColors.gray1,
              fontSize: fontSize,
          ),);
      }
    case BookReadingStatus.done:
      if (startDate.isEmpty) {
        return const SizedBox.shrink();
      } else {
        return Text(
          '$s ~ $f',
          style: TextStyle(
              fontFamily: 'InriaSansRegular',
              color: AppColors.gray1,
              fontSize: fontSize,
          ),);
      }
    default:
      return const SizedBox.shrink();
  }
}