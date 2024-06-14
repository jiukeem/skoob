import 'package:flutter/cupertino.dart';

import 'package:skoob/app/views/pages/bookshelf/overview/widgets/sort_option_list_tile.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

enum SortOption { title, rate, status, startReadingDate, finishReadingDate, category, addedDate }

final Map<String, SortOption> sortOptionMapBottomSheet = {
  '제목순': SortOption.title,
  '평점순': SortOption.rate,
  '상태순': SortOption.status,
  '시작한 날짜순': SortOption.startReadingDate,
  '완독한 날짜순': SortOption.finishReadingDate,
  '카테고리순': SortOption.category,
  '추가한 날짜순': SortOption.addedDate
};

final Map<SortOption, String> sortOptionMapSortIcon = {
  SortOption.title: '제목',
  SortOption.rate: '평점',
  SortOption.status: '상태',
  SortOption.startReadingDate: '시작일',
  SortOption.finishReadingDate: '완독일',
  SortOption.category: '카테고리',
  SortOption.addedDate: '추가일'
};

Widget buildSortOptionBottomSheet(SortOption currentSortOption, bool isAscending) {
  return Container(
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
          'SORT',
          style: TextStyle(
              fontFamily: 'LexendRegular',
              fontSize: 16.0,
              color: AppColors.softBlack
          ),
        ),
        const SizedBox(height: 16.0),
        const GeneralDivider(verticalPadding: 0),
        Expanded(
          child: ListView.builder(
              itemCount: sortOptionMapBottomSheet.keys.length,
              itemBuilder: (context, index) {
                return SortOptionListTile(
                    index: index,
                    currentSortOption: currentSortOption,
                    isAscending: isAscending
                );
              }),
        ),
      ],
    ),
  );
}