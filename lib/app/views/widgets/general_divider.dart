import 'package:flutter/material.dart';
import 'package:skoob/app/utils/app_colors.dart';

class GeneralDivider extends StatelessWidget {
  final double padding;
  const GeneralDivider({super.key, required this.padding} );

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: padding,
      thickness: 0.5,
      color: AppColors.gray2,
    );
  }
}
