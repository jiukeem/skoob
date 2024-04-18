import 'package:skoob/app/models/book.dart';
import 'package:hive/hive.dart';

class BookListManager {
  late Box<Book> _itemsBox;

  Future<void> initBox() async {
    _itemsBox = await Hive.openBox<Book>('bookshelfBox');
  }

  List<Book> get items => _itemsBox.values.toList();

  void _removeDuplicates() {
    var existingKeys = Set<dynamic>();
    var itemsToKeep = <Book>[];

    for (var book in _itemsBox.values) {
      if (!existingKeys.contains(book.basicInfo.isbn13)) {
        itemsToKeep.add(book);
        existingKeys.add(book.basicInfo.isbn13);
      }
    }

    _itemsBox.clear();
    for (var book in itemsToKeep) {
      _itemsBox.add(book);
    }
  }

  void addItem(Book book) {
    if (_itemsBox.values.any((b) => b.basicInfo.isbn13 == book.basicInfo.isbn13)) {
      return;
    }
    _itemsBox.add(book);
  }

  void replaceWithLoadedBookList(List<Book> bookList) {
    _itemsBox.clear();
    _itemsBox.addAll(bookList);
    _removeDuplicates();
  }

  void replaceWithUpdatedBook(Book updatedBook) {
    int index = _itemsBox.values.toList().indexWhere((book) => book.basicInfo.isbn13 == updatedBook.basicInfo.isbn13);
    if (index != -1) {
      _itemsBox.putAt(index, updatedBook);
    }
    _removeDuplicates();
  }

  void deleteItem(Book book) {
    int index = _itemsBox.values.toList().indexWhere((b) => b == book);
    if (index != -1) {
      _itemsBox.deleteAt(index);
    }
  }

  void dispose() {
    _itemsBox.close();
  }
}