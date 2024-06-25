import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/services/book_service.dart';
import 'package:skoob/app/services/third_party/firebase_analytics.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/horizontal_slide_page_route_builder.dart';
import 'package:skoob/app/views/pages/search/search_detail.dart';

class SearchResultViewListTile extends StatefulWidget {
  final Book book;

  const SearchResultViewListTile({super.key, required this.book});

  @override
  State<SearchResultViewListTile> createState() => _SearchResultViewListTileState();
}

class _SearchResultViewListTileState extends State<SearchResultViewListTile> {
  // bool isInBookshelf = false;
  // bool isInWishlist = false;
  final BookService _bookService = BookService();

  @override
  Widget build(BuildContext context) {
    Book book = widget.book;
    return InkWell(
      onTap: () {
        AnalyticsService.logEvent('search_click_detail', parameters: {
          'title': book.basicInfo.title,
        });
        Navigator.push(context, HorizontalSlidePageRoute(SearchDetail(book: book)));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 10.0, 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70.0,
              height: 70 * 70 / 50,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.gray2,
                    width: 0.5,
                  )
              ),
              child: Image.network(
                book.basicInfo.coverImageUrl,
                fit: BoxFit.cover,
              )
            ),
            const SizedBox(width: 8.0,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.basicInfo.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'NotoSansKRMedium',
                      fontSize: 16.0,
                      color: AppColors.softBlack
                    ),
                  ),
                  const SizedBox(height: 4.0,),
                  Text(
                    book.basicInfo.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'NotoSansKRRegular',
                        fontSize: 12.0,
                        color: AppColors.gray1
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
                            fontFamily: 'NotoSansKRRegular',
                            fontSize: 12.0,
                            color: AppColors.gray1
                        ),
                      ),
                      const SizedBox(width: 4.0,),
                      Text(
                        book.basicInfo.pubDate.substring(0,4),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.gray1,
                            fontFamily: 'InriaSansRegular',
                            fontSize: 12.0
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    _bookService.saveBook(book);
                    AnalyticsService.logEvent('search_add_book', parameters: {
                      'title': book.basicInfo.title,
                    });
                    Fluttertoast.showToast(
                      msg: '책을 추가하였습니다: ${book.basicInfo.title}',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 1,
                      backgroundColor: AppColors.gray1,
                      textColor: AppColors.white,
                      fontSize: 14.0,
                    );
                  },
                  icon: const Icon(FluentIcons.add_square_multiple_20_regular),
                ),
                // TODO wishlist
                // IconButton(
                //   onPressed: () {
                //     setState(() {
                //       isInWishlist = !isInWishlist;
                //     });
                //   },
                //   icon: isInWishlist
                //       ? const Icon(FluentIcons.heart_20_filled)
                //       : const Icon(FluentIcons.heart_20_regular),
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
