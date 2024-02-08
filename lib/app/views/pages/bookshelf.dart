import 'package:flutter/material.dart';
import 'package:skoob/app/controller/shared_list_state.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Bookshelf extends StatefulWidget {
  const Bookshelf({super.key});

  @override
  State<Bookshelf> createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  BookshelfStatus _currentStatus = BookshelfStatus.loading;

  @override
  void initState() {
    super.initState();
    _loadLocalBookList();
  }

  Future<void> _loadLocalBookList() async {
    final SharedPreferences localPrefs = await SharedPreferences.getInstance();
    final String? booksJson = localPrefs.getString('books');
    if (booksJson == null) {
      setState(() {
        _currentStatus = BookshelfStatus.complete;
      });
      return;
    };

    List<dynamic> bookMaps = jsonDecode(booksJson);
    List<Book> localBookList = bookMaps.map((bookMap) => Book.fromJson(bookMap))
        .toList();
    Future.microtask(() => Provider.of<SharedListState>(context, listen: false)
        .replaceWithLoadedBookList(localBookList));
    setState(() {
      _currentStatus = BookshelfStatus.complete;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SharedListState listener = Provider.of<SharedListState>(context);

    return SafeArea(
        child: Center(
          child: _buildContentBasedOnBookshelfStatus(listener),
        )
    );
  }

  Widget _buildContentBasedOnBookshelfStatus(SharedListState listener) {
    switch (_currentStatus) {
      case BookshelfStatus.loading:
        return SpinKitRotatingCircle(
          size: 30.0,
          color: Colors.purple[100],
        );
      case BookshelfStatus.complete:
        if (listener.items.length == 0) {
          return Center(
            child: Text('책장에 책이 없습니다.'),
          );
        } else {
          return ListView.builder(
            itemCount: listener.items.length,
            itemBuilder: (context, index) {
              Book book = listener.items[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                leading: ClipRect(
                  child: Image.network(
                    book.coverImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        }
    }
  }
}

enum BookshelfStatus { loading, complete }
