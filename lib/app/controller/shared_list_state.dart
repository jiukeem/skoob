import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:skoob/app/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedListState with ChangeNotifier {
  List<Book> _items = [];
  List<Book> get items => _items;

  void addItem(Book book) {
    _items.add(book);
    _removeDuplicates();
    _saveItemInLocal();
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

  Future<void> _saveItemInLocal() async {
    final SharedPreferences localPrefs = await SharedPreferences.getInstance();
    String booksJson = jsonEncode(_items.map((book) => book.toJson()).toList());
    await localPrefs.setString('books', booksJson);
    return;
  }

  void replaceWithLoadedBookList(List<Book> bookList) {
    _items = bookList;
    notifyListeners();
  }
}