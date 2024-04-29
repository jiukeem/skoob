import 'package:flutter/material.dart';

import 'package:skoob/app/utils/app_colors.dart';

class GeneralDivider extends StatelessWidget {
  final double verticalPadding;
  const GeneralDivider({super.key, required this.verticalPadding} );

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: verticalPadding,
      thickness: 0.5,
      color: AppColors.gray2,
    );
  }
}
