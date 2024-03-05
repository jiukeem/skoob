import 'package:flutter/material.dart';
import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/widgets/status_label.dart';
import '../../services/bookshelf_list_tile_mixin.dart';
import '../pages/book_detail.dart';

class TableViewListTile extends StatelessWidget with BookshelfListTileMixin {
  TableViewListTile({super.key, required Book book, required bool isLast}) {
    this.book = book;
    this.isLast = isLast;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                const SizedBox(
                  width: 32.0,
                  child: Center(
                    child: Text(
                      '7',
                      style: TextStyle(
                        fontFamily: 'InriaSansBold',
                        fontSize: 15.0,
                        color: AppColors.softBlack,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0,),
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
                            fontFamily: 'NotoSansKRBold',
                            color: AppColors.softBlack,
                          ),
                        ),
                        Text(
                          book.basicInfo.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.0,
                            fontFamily: 'NotoSansKRLight',
                            color: AppColors.gray1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    book.customInfo.status == BookReadingStatus.initial
                    ? const SizedBox(height: 20.0)
                    : StatusLabel(book.customInfo.status, 11.0),
                    const SizedBox(height: 2.0,),
                    const Text(
                      '02.06~02.25',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontFamily: 'InriaSansLight',
                        color: AppColors.gray1,
                      ),
                    ),
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