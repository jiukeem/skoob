import 'package:flutter/material.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/book_detail.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';
import 'package:skoob/app/views/widgets/rate_star.dart';
import 'package:skoob/app/views/widgets/status_label.dart';
import 'package:skoob/app/views/widgets/bookshelf_list_tile_mixin.dart';
import 'package:skoob/app/views/widgets/date_widget_accroding_to_status.dart';

class DetailViewListTile extends StatelessWidget with BookshelfListTileMixin {
  DetailViewListTile({super.key, required Book book, required bool isLast}) {
    this.book = book;
    this.isLast = isLast;
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
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => BookDetail(book: book),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      })
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 168.0,
                    width: 120.0,
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
                              book.basicInfo.pubDate.substring(0,4),
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
