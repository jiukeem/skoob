import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/controller/shared_list_state.dart';

import '../../models/book.dart';
import '../../utils/app_colors.dart';

class SearchResultViewListTile extends StatefulWidget {
  final Book book;

  const SearchResultViewListTile({super.key, required this.book});

  @override
  State<SearchResultViewListTile> createState() => _SearchResultViewListTileState();
}

class _SearchResultViewListTileState extends State<SearchResultViewListTile> {
  bool isInBookshelf = false;
  bool isInWishlist = false;

  @override
  Widget build(BuildContext context) {
    Book book = widget.book;
    return Padding(
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
              book.coverImageUrl,
              fit: BoxFit.cover,
            )
          ),
          const SizedBox(width: 8.0,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoSansKRBold',
                    fontSize: 16.0,
                    color: AppColors.softBlack
                  ),
                ),
                const SizedBox(height: 4.0,),
                Text(
                  book.author,
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
                      book.publisher,
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
                      book.pubDate.substring(0,4),
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
                  setState(() {
                    isInBookshelf = !isInBookshelf;
                    Provider.of<SharedListState>(context, listen: false).addItem(book);
                  });
                },
                icon: isInBookshelf
                    ? const Icon(FluentIcons.add_square_multiple_20_filled)
                    : const Icon(FluentIcons.add_square_multiple_20_regular),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    isInWishlist = !isInWishlist;
                  });
                },
                icon: isInWishlist
                    ? const Icon(FluentIcons.heart_20_filled)
                    : const Icon(FluentIcons.heart_20_regular),
              )
            ],
          ),
        ],
      ),
    );
  }
}
