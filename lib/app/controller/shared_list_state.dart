import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:skoob/app/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedListState with ChangeNotifier {
  List<Book> _items = [];
  List<Book> get items => _items;

  void _saveItemInLocal() async {
    final SharedPreferences localPrefs = await SharedPreferences.getInstance();
    String booksJson = jsonEncode(_items.map((book) => book.toJson()).toList());
    localPrefs.setString('books', booksJson);
    return;
  }

  void updateItems(List<Book> Function(List<Book>) updateFunc)  {
    _items = updateFunc(_items);
    _removeDuplicates();
    _saveItemInLocal();
    notifyListeners();
  }

  void _removeDuplicates() {
    _items = _items.toSet().toList();
  }

  void addItem(Book book) {
    updateItems((items) => [...items, book]);
  }

  void replaceWithLoadedBookList(List<Book> bookList) {
    updateItems((_) => bookList);
  }

  void replaceWithUpdatedBook(Book updatedBook) {
    _updateItems((items) {
      int index = items.indexWhere((book) => book.basicInfo.isbn13 == updatedBook.basicInfo.isbn13);
      if (index != -1) {
        items[index] = updatedBook;
        return items;
      }
      return items;
    });
  }

  void deleteItem(Book book) {
    updateItems((items) => items.where((item) => item != book).toList());
  }
}