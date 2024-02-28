import 'package:flutter/material.dart';

import '../../models/book.dart';

class BookDetailNoteListViewTile extends StatefulWidget {
  final Book book;

  const BookDetailNoteListViewTile({super.key, required this.book});

  @override
  State<BookDetailNoteListViewTile> createState() => _BookDetailNoteListViewTileState();
}

class _BookDetailNoteListViewTileState extends State<BookDetailNoteListViewTile> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('note content'),);
  }
}
