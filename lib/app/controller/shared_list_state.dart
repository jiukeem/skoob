import 'package:flutter/cupertino.dart';
import 'package:skoob/app/models/book.dart';

class SharedListState with ChangeNotifier {
  List<Book> _items = [];
  List<Book> get items => _items;

  void addItem(Book book) {
    _items.add(book);
    _removeDuplicates();
    notifyListeners();
  }

  void _removeDuplicates() {
    final List<Book> uniqueList = [];
    final Set<Book> seen = {};
    for (var book in _items) {
      if (seen.add(book)) {
        uniqueList.add(book);
      }
    }
    _items = uniqueList;
    return;
  }
}