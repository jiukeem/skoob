import 'package:flutter/material.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/services/third_party/firebase_analytics.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/bookshelf/detail/book_detail.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';
import 'package:skoob/app/views/pages/bookshelf/widgets/rate_star.dart';
import 'package:skoob/app/views/pages/bookshelf/widgets/status_label.dart';
import 'package:skoob/app/views/pages/bookshelf/overview/widgets/bookshelf_list_tile_mixin.dart';
import 'package:skoob/app/views/pages/bookshelf/detail/widgets/info/date_widget_according_to_status.dart';

import '../../../horizontal_slide_page_route_builder.dart';

class DetailViewListTile extends StatelessWidget with BookshelfListTileMixin {
  DetailViewListTile({super.key, required Book book, required bool isLast, bool isClickable = true}) {
    this.book = book;
    this.isLast = isLast;
    this.isClickable = isClickable;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.5),
            child: InkWell(
              onTap: () {
                if (!isClickable) {return;}
                AnalyticsService.logEvent('bookshelf_detail_view_option_book_tapped');
                Navigator.push(
                    context,
                    HorizontalSlidePageRoute(BookDetail(book: book))
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 168.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.gray2,
                        width: 0.4
                      )
                    ),
                    child: Image.network(
                      book.basicInfo.coverImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.basicInfo.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.softBlack,
                              fontFamily: 'NotoSansKRMedium',
                              fontSize: 16.0
                          ),
                        ),
                        const SizedBox(height: 4.0,),
                        Text(
                          book.basicInfo.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.softBlack,
                              fontFamily: 'NotoSansKRRegular',
                              fontSize: 12.0
                          ),
                        ),
                        const SizedBox(height: 4.0,),
                        Row(
                          children: [
                            Text(
                              book.basicInfo.publisher,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.softBlack,
                                  fontFamily: 'NotoSansKRRegular',
                                  fontSize: 12.0
                              ),
                            ),
                            const SizedBox(width: 4.0,),
                            Text(
                              book.basicInfo.pubDate.length >= 4
                                  ? book.basicInfo.pubDate.substring(0, 4)
                                  : "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.softBlack,
                                  fontFamily: 'InriaSansRegular',
                                  fontSize: 12.0
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6.0,),
                        Container(
                          color: AppColors.gray3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
                            child: Text(
                              book.basicInfo.category.split('>')[1],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.softBlack,
                                  fontFamily: 'NotoSansKRRegular',
                                  fontSize: 12.0
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0,),
                        Row(
                          children: [
                            StatusLabel(book.customInfo.status, 11.0),
                            book.customInfo.status != BookReadingStatus.initial
                            ? const SizedBox(width: 8.0)
                            : const SizedBox.shrink(),
                            dateWidgetAccordingToStatus(
                              12.0,
                              book.customInfo.status,
                              startDate: book.customInfo.startReadingDate,
                              finishDate: book.customInfo.finishReadingDate
                            )
                          ],
                        ),
                        const SizedBox(height: 4.0,),
                        RateStar(rateAsString: book.customInfo.rate, size: 20.0)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLast)
            const SizedBox(
              height: 92.0,
            )
          else
            const GeneralDivider(verticalPadding: 20.0,)
        ],
      ),
    );
  }
}