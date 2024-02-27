import 'package:flutter/material.dart';

import '../../models/book.dart';

class BookDetail extends StatefulWidget {
  final Book book;

  const BookDetail({super.key, required this.book});

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('book detail page'),
      ),
    );
  }
}
