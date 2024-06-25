import 'package:flutter/material.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/bookshelf/detail/book_detail.dart';
import 'package:skoob/app/views/pages/horizontal_slide_page_route_builder.dart';
import 'package:skoob/app/views/pages/bookshelf/widgets/status_label.dart';
import 'package:skoob/app/views/pages/bookshelf/overview/widgets/bookshelf_list_tile_mixin.dart';

import '../../../../../services/third_party/firebase_analytics.dart';

class TableViewListTile extends StatelessWidget with BookshelfListTileMixin {
  TableViewListTile({super.key, required Book book, required bool isLast}) {
    this.book = book;
    this.isLast = isLast;
  }

  String _getCurrentRate() {
    double rate = double.tryParse(book.customInfo.rate) ?? 0.0;
    rate = rate * 2;
    return rate.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: InkWell(
            onTap: () {
              AnalyticsService.logEvent('bookshelf_table_view_option_book_tapped');
              Navigator.push(
                  context,
                  HorizontalSlidePageRoute(BookDetail(book: book))
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                SizedBox(
                    width: 32.0,
                    child: _getCurrentRate() != '0'
                        ? Center(
                            child: Text(
                              _getCurrentRate(),
                              style: const TextStyle(
                                fontFamily: 'InriaSansBold',
                                fontSize: 15.0,
                                color: AppColors.softBlack,
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),
                const SizedBox(
                  width: 12.0,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.basicInfo.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontFamily: 'NotoSansKRMedium',
                            color: AppColors.softBlack,
                          ),
                        ),
                        Text(
                          book.basicInfo.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.0,
                            fontFamily: 'NotoSansKRRegular',
                            color: AppColors.gray1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 3.0,),
                    book.customInfo.status == BookReadingStatus.initial
                    ? const SizedBox(height: 20.0)
                    : StatusLabel(book.customInfo.status, 11.0),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isLast)
          const SizedBox(height: 92.0,)
        else
          const SizedBox(height: 12.0,)
      ],
    );
  }
}