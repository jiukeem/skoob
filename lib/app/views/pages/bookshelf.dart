import 'package:flutter/material.dart';

class Bookshelf extends StatefulWidget {
  const Bookshelf({super.key});

  @override
  State<Bookshelf> createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('책장에 책이 없습니다.'),
      ),
    );
  }
}
