import 'package:flutter/material.dart';

import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/utils/app_colors.dart';

class StatusLabel extends StatelessWidget {
  final BookReadingStatus status;
  final double fontSize;

  const StatusLabel(this.status, [this.fontSize = 14]);

  @override
  Widget build(BuildContext context) {
    return _buildWidgetBasedOnStatusAndFontSize();
  }

  Widget _buildWidgetBasedOnStatusAndFontSize() {
    switch (status) {
      case BookReadingStatus.initial:
        return const SizedBox.shrink();
      case BookReadingStatus.notStarted:
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.gray2,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
            child: Text(
              'not started',
              style: TextStyle(
                  fontFamily: 'LexendRegular',
                  color: AppColors.white,
                  fontSize: fontSize),
            ),
          ),
        );
      case BookReadingStatus.reading:
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.secondaryYellow,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
            child: Text(
              'reading',
              style: TextStyle(
                  fontFamily: 'LexendRegular',
                  color: AppColors.softBlack,
                  fontSize: fontSize),
            ),
          ),
        );
      case BookReadingStatus.done:
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.softBlack,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
            child: Text(
              'done',
              style: TextStyle(
                  fontFamily: 'LexendRegular',
                  color: AppColors.white,
                  fontSize: fontSize),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
