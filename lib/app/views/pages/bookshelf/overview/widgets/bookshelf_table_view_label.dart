import 'package:flutter/material.dart';

import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

class TableViewLabel extends StatelessWidget {
  const TableViewLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
              children: [
                Text(
                  'RATE',
                  style: TextStyle(
                    fontFamily: 'LexendRegular',
                    fontSize: 12.0,
                    color: AppColors.gray1,
                  ),
                ),
                SizedBox(width: 12.0,),
                Text(
                  'BOOK',
                  style: TextStyle(
                    fontFamily: 'LexendRegular',
                    fontSize: 12.0,
                    color: AppColors.gray1,
                  ),

                ),
                Spacer(),
                Text(
                  'STATUS',
                  style: TextStyle(
                    fontFamily: 'LexendRegular',
                    fontSize: 12.0,
                    color: AppColors.gray1,
                  ),
                ),
              ]
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: GeneralDivider(verticalPadding: 12.0,),
        ),
      ],
    );
  }
}
