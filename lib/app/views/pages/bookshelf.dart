import 'package:flutter/material.dart';
import 'package:skoob/app/controller/shared_list_state.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class Bookshelf extends StatefulWidget{
  const Bookshelf({super.key});

  @override
  State<Bookshelf> createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  BookshelfStatus _currentStatus = BookshelfStatus.loading;
  BookshelfViewOption _currentViewOption = BookshelfViewOption.detail;

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

  void _deleteSelectedBook(Book book) {
    Provider.of<SharedListState>(context, listen: false).deleteItem(book);
  }

  @override
  Widget build(BuildContext context) {
    final SharedListState listener = Provider.of<SharedListState>(context);

    return SafeArea(
        child: Column(
          children: [
            _buildBookshelfAppBar(),
            _buildContentBasedOnBookshelfStatus(listener),
          ],
        )
    );
  }

  Widget _buildBookshelfAppBar() {
    return SizedBox(
      height: 60.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 8.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'MY BOOKS',
              style: TextStyle(
                  fontFamily: 'LexendExaMedium',
                  fontSize: 24.0
              ),
            ),
            Row(
              children: [
                _viewOptionItem(viewOption: BookshelfViewOption.detail,
                    defaultIcon: const Icon(FluentIcons.apps_list_detail_24_regular, color: AppColors.gray2),
                    selectedIcon: const Icon(FluentIcons.apps_list_detail_24_filled, color: AppColors.softBlack)
                ),
                _viewOptionItem(viewOption: BookshelfViewOption.table,
                    defaultIcon: const Icon(FluentIcons.navigation_24_regular, color: AppColors.gray2),
                    selectedIcon: const Icon(FluentIcons.navigation_24_filled, color: AppColors.softBlack)
                ),
                _viewOptionItem(viewOption: BookshelfViewOption.album,
                    defaultIcon: const Icon(FluentIcons.grid_24_regular, color: AppColors.gray2),
                    selectedIcon: const Icon(FluentIcons.grid_24_filled, color: AppColors.softBlack)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewOptionItem({required BookshelfViewOption viewOption, required Icon defaultIcon, required Icon selectedIcon}) {
    bool isSelected = viewOption == _currentViewOption;
    return IconButton(
        onPressed: () {
          setState(() {
            _currentViewOption = viewOption;
          });
        },
        icon: isSelected ? selectedIcon : defaultIcon
    );
  }

  Widget _buildContentBasedOnBookshelfStatus(SharedListState listener) {
    switch (_currentStatus) {
      case BookshelfStatus.loading:
        return const SpinKitRotatingCircle(
          size: 30.0,
          color: AppColors.primaryYellow,
        );
      case BookshelfStatus.complete:
        if (listener.items.isEmpty) {
          return const Expanded(
            child: Center(
              child: Text('추가한 책이 없습니다'),
            ),
          );
        } else {
          return Expanded(
            child: Column(
              children: [
                // TODO filter & sorting
                ListView.builder(
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
                      trailing: IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () {
                          _deleteSelectedBook(book);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }
    }
  }
}

enum BookshelfStatus { loading, complete }
enum BookshelfViewOption { detail, table, album }
