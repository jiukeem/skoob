import 'package:flutter/material.dart';
import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/models/skoob_user.dart';
import 'package:skoob/app/services/book_service.dart';
import 'package:skoob/app/services/third_party/firebase_analytics.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/bookshelf/overview/widgets/detail_view_list_tile.dart';
import 'package:skoob/app/views/pages/bookshelf/overview/widgets/sort_option_bottom_sheet.dart';
import 'package:skoob/app/views/pages/bookshelf/overview/widgets/table_view_label.dart';
import 'package:skoob/app/views/pages/bookshelf/overview/builder/bookshelf_album_view_builder.dart';
import 'package:skoob/app/views/pages/bookshelf/overview/widgets/table_view_list_tile.dart';
import 'package:skoob/config/config.dart';

class Bookshelf extends StatefulWidget{
  final bool isVisiting;
  final SkoobUser? hostUser;
  const Bookshelf({super.key, this.isVisiting = false, this.hostUser});

  @override
  State<Bookshelf> createState() => _BookshelfState();
}

class _BookshelfState extends State<Bookshelf> {
  final BookService _bookService = BookService();
  BookshelfViewOption _currentViewOption = BookshelfViewOption.detail;
  SortOption _currentSortOption = SortOption.addedDate;
  bool _isAscending = true;
  bool _isLoading = true;
  List<Book> friendBooks = [];

  @override
  void initState() {
    super.initState();

    if (!widget.isVisiting) {
      _initSync();
    } else {
      _getFriendBookshelf();
    }
  }

  void _initSync() async {
    await _checkLocalAndServerSync();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkLocalAndServerSync() async {
    DateTime? localLastModified = await _bookService.getLastModifiedTimeInHive();
    DateTime? serverLastModified = await _bookService.getLastModifiedTimeInFirestore();

    if (localLastModified == null && serverLastModified == null) return;

    if (localLastModified == null) {
      // re-installed case
      await _syncFromServer();
      return;
    }

    if (serverLastModified == null) {
      // server is not updated
      await _syncFromLocal();
      return;
    }

    final diff = localLastModified.difference(serverLastModified);
    if (diff < const Duration(seconds: 5)) {
      // consider they are synchronized
      return;
    }

    if (serverLastModified.isAfter(localLastModified)) {
      await _syncFromServer();
    } else if (localLastModified.isAfter(serverLastModified)) {
      _syncFromLocal();
    }
    return;
  }

  Future<void> _syncFromServer() async {
    AnalyticsService.logEvent('bookshelf_start_sync_from_server');
    await _bookService.syncBookshelfFromServer();
  }

  Future<void> _syncFromLocal() async {
    AnalyticsService.logEvent('bookshelf_start_sync_from_local');
    await _bookService.syncBookshelfFromLocal();
  }

  void _getFriendBookshelf() async {
    if (widget.hostUser == null) {
      return;
    }

    friendBooks = await _bookService.getFriendBookshelf(widget.hostUser!.email);
    setState(() {
      _isLoading = false;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisiting) {
      return SafeArea(
          child: Column(
            children: [
              _buildBookshelfAppBar(),
              ValueListenableBuilder(
                valueListenable: Hive.box<Book>(bookBoxName).listenable(),
                builder: (context, Box<Book> box, _) {
                  var books = box.values.toList();
                  return _buildContentBasedOnBookshelfStatus(books);
                },
              ),
            ],
          ));
    } else {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
            child: Column(
              children: [
                _buildBookshelfAppBar(),
                _buildContentBasedOnBookshelfStatus(friendBooks)
              ],
            )),
      );
    }
  }

  Widget _buildBookshelfAppBar() {
    if (!widget.isVisiting) {
      return SizedBox(
        height: 56.0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 8.0, 0),
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
    } else {
      final friendName = widget.hostUser?.name ?? '';
      return SizedBox(
        height: 56.0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 12,),
              Text(
              friendName,
              style: const TextStyle(
                  fontFamily: 'LexendExaMedium', fontSize: 24.0),
              ),
            ]
          ),
        ),
      );
    }

  }

  Widget _viewOptionItem({required BookshelfViewOption viewOption, required Icon defaultIcon, required Icon selectedIcon}) {
    bool isSelected = viewOption == _currentViewOption;
    return IconButton(
        onPressed: () {
          AnalyticsService.logEvent('bookshelf_view_option_changed',
              parameters: {
                'view_option_from': _currentViewOption.toString(),
                'view_option_to': viewOption.toString()
              });
          setState(() {
            _currentViewOption = viewOption;
          });
        },
        icon: isSelected ? selectedIcon : defaultIcon
    );
  }

  Widget _buildContentBasedOnBookshelfStatus(List<Book> books) {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: SpinKitRotatingCircle(
            size: 30.0,
            color: AppColors.primaryYellow,
          ),
        ),
      );
    } else {
      if (books.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text('아직 추가한 책이 없습니다'),
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
                        AnalyticsService.logEvent('bookshelf_tap_sort_option');
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
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(9, 3, 8, 4),
                          child: Row(
                            children: [
                              Text(
                                sortOptionMapSortIcon[_currentSortOption]!,
                                style: const TextStyle(
                                    color: AppColors.gray1,
                                    fontFamily: 'NotoSansKRRegular',
                                    fontSize: 14.0
                                ),
                              ),
                              // const SizedBox(width: 4.0,),
                              Icon(
                                _isAscending ? FluentIcons.chevron_up_16_regular : FluentIcons.chevron_down_16_regular,
                                color: AppColors.gray1,
                                size: 16.0,
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
                    ? BookshelfAlbumViewBuilder(items: _sortBookshelf(books))
                    : ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          List<Book> sortedList = _sortBookshelf(books);
                          Book book = sortedList[index];
                          bool isLast = index + 1 == sortedList.length;
                          if (_currentViewOption ==
                              BookshelfViewOption.detail) {
                            return DetailViewListTile(
                                book: book, isLast: isLast, isClickable: !widget.isVisiting,);
                          } else if (_currentViewOption ==
                              BookshelfViewOption.table) {
                            return TableViewListTile(
                                book: book, isLast: isLast);
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
          return buildSortOptionBottomSheet(_currentSortOption, _isAscending);
        }
    );

    if (result != null) {
      final newSortOption = result['selectedOption'];
      final newIsAscending = result['isAscending'];
      AnalyticsService.logEvent('bookshelf_sort_option_changed', parameters: {
        'sort_option_from': _currentSortOption.toString(),
        'is_ascending_from': _isAscending.toString(),
        'sort_option_to': newSortOption.toString(),
        'is_ascending_to': newIsAscending.toString()
      });
      setState(() {
         _currentSortOption = newSortOption;
         _isAscending = newIsAscending;
      });
    } else {
      AnalyticsService.logEvent('bookshelf_sort_option_not_changed');
    }
  }
}

enum BookshelfViewOption { detail, table, album }

