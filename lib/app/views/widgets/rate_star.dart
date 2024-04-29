import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:skoob/app/utils/app_colors.dart';

class RateStar extends StatelessWidget {
  final String rateAsString;
  final double size;

  const RateStar({super.key, required this.rateAsString, required this.size});

  @override
  Widget build(BuildContext context) {
    final double rate = double.tryParse(rateAsString) ?? 0.0;
    if (rate == 0.0) {
      return const SizedBox.shrink();
    }
    return RatingBar(
      initialRating: rate,
      itemSize: size,
      direction: Axis.horizontal,
      allowHalfRating: true,
      ignoreGestures: true,
      itemCount: 5,
      ratingWidget: RatingWidget(
        full: const Icon(
            FluentIcons.star_20_filled,
            color: AppColors.secondaryYellow
        ),
        half: const Icon(
            FluentIcons.star_half_20_regular,
            color: AppColors.secondaryYellow
        ),
        empty: const Icon(
            FluentIcons.star_48_regular,
            color: AppColors.secondaryYellow
        ),
      ),
      glow: false,
      onRatingUpdate: (double value) {  },
    );
  }
}
