import 'package:flutter/material.dart';
import 'package:skoob/app/controller/shared_list_state.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:skoob/app/views/widgets/bookshelf_detail_view_list_tile.dart';
import 'package:skoob/app/views/widgets/bookshelf_table_view_label.dart';

import '../../models/book/custom_info.dart';
import '../widgets/bookshelf_album_view_builder.dart';
import '../widgets/bookshelf_table_view_list_tile.dart';
import '../widgets/general_divider.dart';
import '../widgets/sort_option_list_tile.dart';

class Bookshelf extends StatefulWidget{
  const Bookshelf({super.key});

  @override
  State<Bookshelf> createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  BookshelfStatus _currentStatus = BookshelfStatus.loading;
  BookshelfViewOption _currentViewOption = BookshelfViewOption.detail;
  SortOption _currentSortOption = SortOption.addedDate;
  bool _isAscending = true;

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
    }

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
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 8.0, 0),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 20.0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _showSortOptionBottomSheet(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.gray1,
                                width: 0.5,
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(20.0))
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  FluentIcons.arrow_sort_16_regular,
                                  color: AppColors.gray1,
                                  size: 14.0,
                                ),
                                SizedBox(width: 4.0,),
                                Text(
                                  'sort',
                                  style: TextStyle(
                                      color: AppColors.gray1,
                                      fontFamily: 'LexendRegular',
                                      fontSize: 16.0
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0,),
                      // TODO implement filter
                      // Container(
                      //   decoration: BoxDecoration(
                      //       border: Border.all(
                      //         color: AppColors.gray1,
                      //         width: 0.5,
                      //       ),
                      //       borderRadius: const BorderRadius.all(Radius.circular(20.0))
                      //   ),
                      //   child: const Padding(
                      //     padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                      //     child: Row(
                      //       children: [
                      //         Icon(
                      //           FluentIcons.options_16_regular,
                      //           color: AppColors.gray1,
                      //           size: 14.0,
                      //         ),
                      //         SizedBox(width: 4.0,),
                      //         Text(
                      //           'filter',
                      //           style: TextStyle(
                      //               color: AppColors.gray1,
                      //               fontFamily: 'LexendRegular',
                      //               fontSize: 14.0
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                if (_currentViewOption == BookshelfViewOption.table)
                  const TableViewLabel(),
                Expanded(
                  child: _currentViewOption == BookshelfViewOption.album
                      ? BookshelfAlbumViewBuilder(items: _sortBookshelf(listener.items))
                      : ListView.builder(
                          itemCount: listener.items.length,
                          itemBuilder: (context, index) {
                            List<Book> sortedList = _sortBookshelf(listener.items);
                            Book book = sortedList[index];
                            bool isLast = index + 1 == sortedList.length;
                            if (_currentViewOption == BookshelfViewOption.detail) {
                              return DetailViewListTile(book: book, isLast: isLast);
                            } else if (_currentViewOption == BookshelfViewOption.table) {
                              return TableViewListTile(book: book, isLast: isLast);
                            } else {
                              return ListTile(title: Text(book.basicInfo.title));
                            }
                          },
                        ),
                ),
              ],
            ),
          );
        }
    }
  }

  List<Book> _sortBookshelf(List<Book> list) {
    int statusComparator(BookReadingStatus a, BookReadingStatus b) {
      const order = {
        BookReadingStatus.initial: 0,
        BookReadingStatus.notStarted: 1,
        BookReadingStatus.reading: 2,
        BookReadingStatus.done: 3,
      };
      return order[a]!.compareTo(order[b]!);
    }

    switch (_currentSortOption) {
      case SortOption.title:
        list.sort((a, b) => a.basicInfo.title.compareTo(b.basicInfo.title));
        break;
      case SortOption.rate:
        list.sort((a, b) => a.customInfo.rate.compareTo(b.customInfo.rate));
        break;
      case SortOption.status:
        list.sort((a, b) => statusComparator(a.customInfo.status, b.customInfo.status));
        break;
      case SortOption.startReadingDate:
        list.sort((a, b) => a.customInfo.startReadingDate.compareTo(b.customInfo.startReadingDate));
        break;
      case SortOption.finishReadingDate:
        list.sort((a, b) => a.customInfo.finishReadingDate.compareTo(b.customInfo.finishReadingDate));
        break;
      case SortOption.category:
        list.sort((a, b) => a.basicInfo.category.compareTo(b.basicInfo.category));
        break;
      case SortOption.addedDate:
        list.sort((a, b) => a.customInfo.addedDate.compareTo(b.customInfo.addedDate));
        break;
    }

    if (!_isAscending) {
      list = list.reversed.toList();
    }

    return list;
  }

  Future<void> _showSortOptionBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)
                )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12.0),
                Container(
                  width: 64,
                  height: 2,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: AppColors.gray2,
                  ),
                ),
                const SizedBox(height: 18.0),
                const Text(
                  'SORT',
                  style: TextStyle(
                      fontFamily: 'LexendRegular',
                      fontSize: 16.0,
                      color: AppColors.softBlack
                  ),
                ),
                const SizedBox(height: 16.0),
                const GeneralDivider(verticalPadding: 0),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortOptionMap.keys.length,
                    itemBuilder: (context, index) {
                      return SortOptionListTile(
                          index: index,
                          currentSortOption: _currentSortOption,
                          isAscending: _isAscending
                      );
                    }),
                ),
              ],
            ),
          );
        }
    );

    if (result != null) {
      setState(() {
         _currentSortOption = result['selectedOption'];
         _isAscending = result['isAscending'];
      });
    }
  }
}

enum BookshelfStatus { loading, complete }
enum BookshelfViewOption { detail, table, album }
enum SortOption { title, rate, status, startReadingDate, finishReadingDate, category, addedDate }

final Map<String, SortOption> sortOptionMap = {
  '제목순': SortOption.title,
  '평점순': SortOption.rate,
  '상태순': SortOption.status,
  '시작한 날짜순': SortOption.startReadingDate,
  '완독한 날짜순': SortOption.finishReadingDate,
  '카테고리순': SortOption.category,
  '추가한 날짜순': SortOption.addedDate
};

