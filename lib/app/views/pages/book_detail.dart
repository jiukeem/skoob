import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/controller/book_list_manager.dart';
import 'package:skoob/app/views/pages/user_record.dart';

import '../../models/book.dart';
import '../../utils/app_colors.dart';
import '../widgets/book_detail_highlight_list_view_tile.dart';
import '../widgets/book_detail_info_list_view_tile.dart';
import '../widgets/book_detail_note_list_view_tile.dart';

class BookDetail extends StatefulWidget {
  final Book book;

  const BookDetail({super.key, required this.book});

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late Book book;
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    book = widget.book;
    _currentRating = double.tryParse(book.customInfo.rate) ?? 0.0;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void navigateAndUpdateUserRecord(BuildContext context, String existingComment, UserRecordOption userRecordOption) async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation,
                secondaryAnimation) =>
                UserRecord(book: book, existingRecord: existingComment, userRecordOption: userRecordOption,),
            transitionsBuilder: (context, animation,
                secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));
              var offsetAnimation =
              animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            }));

    // back from UserRecord page, with result
    if (result != null) {
      setState(() {
        book = result as Book;
      });
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    Widget cancelButton = InkWell(
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        child: Text(
          '취소',
          style: TextStyle(
            fontFamily: 'NotoSansKRMedium',
            fontSize: 14.0,
            color: AppColors.softBlack,
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop(false);
      },
    );

    Widget deleteButton = InkWell(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          color: AppColors.warningRed,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
          child: Text(
            '삭제',
            style: TextStyle(
              fontFamily: 'NotoSansKRMedium',
              fontSize: 14.0,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      title: Text(
          book.basicInfo.title,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'NotoSansKRBold',
          fontSize: 16.0,
          color: AppColors.softBlack,
        ),
      ),
      content: const Text('해당 도서를 목록에서 삭제할까요?\n이 작업은 돌이킬 수 없습니다'),
      actions: [
        cancelButton,
        deleteButton,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );

    final bool? shouldDelete = await showDialog(
        context: context,
        builder: (context) {
          return alert;
        });

    if (mounted && shouldDelete == true) {
      Navigator.of(context).pop();
      Provider.of<BookListManager>(context, listen: false).deleteItem(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: Theme(
          data: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppColors.white
            )
          ),
          child: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: AppColors.white,
                    surfaceTintColor: AppColors.white,
                    pinned: true,
                    floating: false,
                    actions: [
                      PopupMenuButton<int>(
                        surfaceTintColor: AppColors.white,
                        icon: const Icon(FluentIcons.more_vertical_24_regular), // Menu icon
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            value: 1,
                            child: Row(
                              children: [
                                Text(
                                  '책 삭제하기',
                                  style: TextStyle(
                                    color: AppColors.warningRed,
                                    fontSize: 14.0,
                                    fontFamily: 'NotoSansKRRegular'
                                  ),
                                ),
                                SizedBox(width: 8.0,),
                                Icon(
                                  FluentIcons.delete_24_regular,
                                  color: AppColors.warningRed,
                                  size: 16.0,
                                )
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 1) {
                            _showDeleteDialog(context);
                          }
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120.0,
                            height: 168.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.gray3,
                                width: 0.5,
                              )
                            ),
                            child: Image.network(
                              book.basicInfo.coverImageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            book.basicInfo.title,
                            style: const TextStyle(
                              fontFamily: 'NotoSansKRMedium',
                              fontSize: 16.0,
                              color: AppColors.softBlack
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          RatingBar(
                            initialRating: _currentRating,
                            unratedColor: AppColors.gray3,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            ratingWidget: RatingWidget(
                              full: Icon(
                                  FluentIcons.star_20_filled,
                                  color: _currentRating > 0 ? AppColors.secondaryYellow : AppColors.gray3
                              ),
                              half: Icon(
                                  FluentIcons.star_half_20_regular,
                                  color: _currentRating > 0 ? AppColors.secondaryYellow : AppColors.gray3
                              ),
                              empty: Icon(
                                  FluentIcons.star_48_regular,
                                  color: _currentRating > 0 ? AppColors.secondaryYellow : AppColors.gray3
                              ),
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                if (rating == _currentRating) {
                                  _currentRating = 0.0;
                                } else {
                                  _currentRating = rating;
                                }
                              });
                              book.customInfo.rate = rating.toString();
                              Provider.of<BookListManager>(context, listen: false).replaceWithUpdatedBook(book);
                            },
                            glow: false,
                          ),
                          const SizedBox(height: 8.0),
                          InkWell(
                          onTap: () {
                            navigateAndUpdateUserRecord(context, book.customInfo.comment, UserRecordOption.comment);
                          },
                          child: book.customInfo.comment.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        const BorderRadius.all(Radius.circular(20.0)),
                                    border: Border.all(
                                      color: AppColors.gray1,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '한 줄 소감 남기기',
                                        style: TextStyle(
                                            fontFamily: 'NotoSansKRLight',
                                            fontSize: 12.0,
                                            color: AppColors.gray1),
                                      ),
                                      Icon(
                                        FluentIcons.edit_16_regular,
                                        color: AppColors.gray1,
                                        size: 12.0,
                                      ),
                                    ],
                                  ),
                                )
                              : Text(
                                  book.customInfo.comment,
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'NotoSansKrRegular',
                                    fontSize: 12.0,
                                    color: AppColors.softBlack,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'INFO'),
                            // Tab(text: 'NOTE'),
                            // Tab(text: 'HIGHLIGHT'),
                          ],
                          labelStyle: const TextStyle(
                            fontFamily: 'LexendMedium',
                            fontSize: 16.0,
                            color: AppColors.primaryGreen
                          ),
                          unselectedLabelStyle: const TextStyle(
                              fontFamily: 'LexendLight',
                              fontSize: 16.0,
                          ),
                          unselectedLabelColor: AppColors.gray2,
                          dividerColor: AppColors.gray2,
                          indicatorColor: AppColors.primaryGreen,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                          tabAlignment: TabAlignment.center,
                          isScrollable: true,
                          dividerHeight: 0.5,
                        ),
                      ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                      itemCount: infoLabelList.length,
                      itemBuilder: (context, index) {
                        return BookDetailInfoListViewTile(book: book, index: index);
                    }),
                  ),
                  // Column(
                  //   children: [
                  //     Padding(
                  //       padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
                  //       child: InkWell(
                  //         onTap: () {
                  //           navigateAndUpdateUserRecord(context, '', UserRecordOption.note);
                  //         },
                  //         child: Container(
                  //           height: 28.0,
                  //           decoration: const BoxDecoration(
                  //             borderRadius: BorderRadius.all(Radius.circular(5)),
                  //             color: AppColors.gray3,
                  //           ),
                  //           child: const Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               Text(
                  //                 '노트 추가하기',
                  //                 style: TextStyle(
                  //                   fontSize: 12.0,
                  //                   fontFamily: 'NotoSansKRRegular',
                  //                   color: AppColors.gray1,
                  //                 ),
                  //               ),
                  //               Icon(FluentIcons.add_circle_16_regular,
                  //               color: AppColors.gray1,
                  //               size: 16.0,)
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: ListView.builder(
                  //           padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                  //           itemCount: book.customInfo.note.length,
                  //           itemBuilder: (context, index) {
                  //             MapEntry<String, String> item = book.customInfo.note.entries.elementAt(index);
                  //             return BookDetailNoteListViewTile(note: item);
                  //           }),
                  //     ),
                  //   ],
                  // ),
                  // Column(
                  //   children: [
                  //     Padding(
                  //       padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
                  //       child: InkWell(
                  //         onTap: () {
                  //           navigateAndUpdateUserRecord(context, '', UserRecordOption.highlight);
                  //         },
                  //         child: Container(
                  //           height: 28.0,
                  //           decoration: const BoxDecoration(
                  //             borderRadius: BorderRadius.all(Radius.circular(5)),
                  //             color: AppColors.gray3,
                  //           ),
                  //           child: const Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               Text(
                  //                 '하이라이트 추가하기',
                  //                 style: TextStyle(
                  //                   fontSize: 12.0,
                  //                   fontFamily: 'NotoSansKRRegular',
                  //                   color: AppColors.gray1,
                  //                 ),
                  //               ),
                  //               Icon(FluentIcons.add_circle_16_regular,
                  //                 color: AppColors.gray1,
                  //                 size: 16.0,)
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: ListView.builder(
                  //           padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                  //           itemCount: book.customInfo.highlight.length,
                  //           itemBuilder: (context, index) {
                  //             MapEntry<String, String> item = book.customInfo.highlight.entries.elementAt(index);
                  //             return BookDetailHighlightListViewTile(highlight: item);
                  //           }),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
        color: AppColors.white,
        child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

final List<String> infoLabelList = [
  'Status',
  'Title',
  'Author',
  'Translator',
  'Publisher',
  'Publish Date',
  'Category',
  'Link',
];
