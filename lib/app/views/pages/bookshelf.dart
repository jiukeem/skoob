import 'package:flutter/material.dart';
import 'package:skoob/app/controller/shared_list_state.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/models/book.dart';

class Bookshelf extends StatefulWidget {
  const Bookshelf({super.key});

  @override
  State<Bookshelf> createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  @override
  Widget build(BuildContext context) {
    final SharedListState listener = Provider.of<SharedListState>(context);

    return SafeArea(
        child: Center(
          child: _buildContentBasedOnBookshelfStatus(listener),
        )
    );
  }
}
