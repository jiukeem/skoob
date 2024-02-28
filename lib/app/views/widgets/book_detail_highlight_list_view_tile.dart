import 'package:flutter/material.dart';

import '../../models/book.dart';

class BookDetailHighlightListViewTile extends StatefulWidget {
  final Book book;

  const BookDetailHighlightListViewTile({super.key, required this.book});

  @override
  State<BookDetailHighlightListViewTile> createState() => _BookDetailHighlightListViewTileState();
}

class _BookDetailHighlightListViewTileState extends State<BookDetailHighlightListViewTile> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('highlight content'),);
  }
}
