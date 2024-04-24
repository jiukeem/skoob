import 'package:skoob/app/models/book.dart';
import 'package:hive/hive.dart';

class BookListManager {
  late Box<Book> _itemsBox;

  Future<void> initBox() async {
    _itemsBox = await Hive.openBox<Book>('bookshelfBox');
  }

  List<Book> get items => _itemsBox.values.toList();

  void addItem(Book book) {
    if (_itemsBox.values.any((b) => b.basicInfo.isbn13 == book.basicInfo.isbn13)) {
      return;
    }
    _itemsBox.add(book);
  }

  void replaceWithLoadedBookList(List<Book> bookList) {
    _itemsBox.clear();
    _itemsBox.addAll(bookList);
  }

  void replaceWithUpdatedBook(Book updatedBook) {
    int index = _itemsBox.values.toList().indexWhere((book) => book.basicInfo.isbn13 == updatedBook.basicInfo.isbn13);
    if (index != -1) {
      _itemsBox.putAt(index, updatedBook);
    }
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