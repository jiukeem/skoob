import 'package:flutter/material.dart';
import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/utils/app_colors.dart';
import '../../services/bookshelf_list_tile_mixin.dart';

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
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'NotoSansKRBold',
                          color: AppColors.softBlack,
                        ),
                      ),
                      Text(
                        book.author,
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
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryYellow,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 6.0),
                      child: Text(
                        'reading',
                        style: TextStyle(
                            fontFamily: 'LexendRegular',
                            color: AppColors.softBlack,
                            fontSize: 11.0
                        ),
                      ),
                    ),
                  ),
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
        if (isLast)
          const SizedBox(height: 92.0,)
        else
          const SizedBox(height: 12.0,)
      ],
    );
  }
}