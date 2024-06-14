import 'package:flutter/material.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/views/pages/bookshelf/overview/widgets/album_view_list_tile.dart';

class BookshelfAlbumViewBuilder extends StatefulWidget {
  final List<Book> items;

  const BookshelfAlbumViewBuilder({super.key, required this.items});

  @override
  State<BookshelfAlbumViewBuilder> createState() => _BookshelfAlbumViewBuilderState();
}

class _BookshelfAlbumViewBuilderState extends State<BookshelfAlbumViewBuilder> {
  final double minItemWidth = 72.0;
  final double gap = 8.0;
  final double itemRatio = 75/128;
  final double padding = 20.0;
  int maxItemNum = 4;
  double itemWidth = 75.0;


  void calculateItemSizeAndNum() {
    double screenWidth = MediaQuery.of(context).size.width;
    double availableWidth = screenWidth - padding * 2;
    maxItemNum = (availableWidth + 8) ~/ 80;
    itemWidth = (availableWidth + 8) / (maxItemNum + 8);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 92.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: maxItemNum,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            childAspectRatio: itemRatio
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          Book book = widget.items[index];
          bool isLast = index + 1 == widget.items.length;
          return AlbumViewListTile(book: book, isLast: isLast, itemWidth: itemWidth);
        });
  }
}
