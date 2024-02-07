import 'package:flutter/material.dart';
import 'package:skoob/app/controller/shared_list_state.dart';
import 'package:provider/provider.dart';

class Bookshelf extends StatefulWidget {
  const Bookshelf({super.key});

  @override
  State<Bookshelf> createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  @override
  Widget build(BuildContext context) {
    final SharedListState listener = Provider.of<SharedListState>(context);

    return Center(
      child: (listener.items.length == 0)
          ? Text('책장에 책이 없습니다.')
          : ListView.builder(
          itemCount: listener.items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(listener.items[index].title)
            );
          },
        ),
    );
  }
}
