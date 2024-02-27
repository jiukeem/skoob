import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/utils/app_colors.dart';
import '../../services/bookshelf_list_tile_mixin.dart';
import '../pages/book_detail.dart';

class AlbumViewListTile extends StatelessWidget with BookshelfListTileMixin {
  final double itemWidth;

  AlbumViewListTile({super.key, required Book book, required bool isLast, required this.itemWidth}) {
    this.book = book;
    this.isLast = isLast;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: itemWidth,
            height: itemWidth * 105/75,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.gray3,
                width: 0.5,
              )
            ),
            child: Image.network(
              book.basicInfo.coverImageUrl,
              fit: BoxFit.cover,

            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 2.0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  FluentIcons.star_20_filled,
                  color: AppColors.secondaryYellow,
                  size: 13.0,
                ),
                Icon(
                  FluentIcons.star_20_filled,
                  color: AppColors.secondaryYellow,
                  size: 13.0,
                ),
                Icon(
                  FluentIcons.star_20_filled,
                  color: AppColors.secondaryYellow,
                  size: 13.0,
                ),
                Icon(
                  FluentIcons.star_20_filled,
                  color: AppColors.secondaryYellow,
                  size: 13.0,
                ),
                Icon(
                  FluentIcons.star_half_20_regular,
                  color: AppColors.secondaryYellow,
                  size: 13.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}