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
        return _buildStatusContainer(text: 'not started',
            textColor: AppColors.white,
            backgroundColor: AppColors.gray2);
      case BookReadingStatus.reading:
        return _buildStatusContainer(text: 'reading',
            textColor: AppColors.softBlack,
            backgroundColor: AppColors.secondaryYellow);
      case BookReadingStatus.done:
        return _buildStatusContainer(text: 'reading',
            textColor: AppColors.white,
            backgroundColor: AppColors.softBlack);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusContainer(
      {required String text,
      required Color backgroundColor,
      required Color textColor}) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
        child: Text(
          text,
          style: TextStyle(
              fontFamily: 'LexendRegular',
              color: textColor,
              fontSize: fontSize),
        ),
      ),
    );
  }
}
