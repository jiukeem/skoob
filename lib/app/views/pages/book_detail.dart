import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:skoob/app/views/pages/user_record.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

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
  late final Book book;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    book = widget.book;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void navigateAndUpdateComment(BuildContext context, String existingComment) async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, animation,
                secondaryAnimation) =>
                UserRecord(book: book, existingComment: existingComment),
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
        book.customInfo.comment = result.toString();
      });

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
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                          SizedBox(height: 8.0),
                          Text(
                            book.basicInfo.title,
                            style: TextStyle(
                              fontFamily: 'NotoSansKRMedium',
                              fontSize: 16.0,
                              color: AppColors.softBlack
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FluentIcons.star_20_filled,
                                color: AppColors.secondaryYellow,
                                size: 32.0,
                              ),
                              Icon(
                                FluentIcons.star_20_filled,
                                color: AppColors.secondaryYellow,
                                size: 32.0,
                              ),
                              Icon(
                                FluentIcons.star_20_filled,
                                color: AppColors.secondaryYellow,
                                size: 32.0,
                              ),
                              Icon(
                                FluentIcons.star_20_filled,
                                color: AppColors.secondaryYellow,
                                size: 32.0,
                              ),
                              Icon(
                                FluentIcons.star_half_20_regular,
                                color: AppColors.secondaryYellow,
                                size: 32.0,
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          InkWell(
                          onTap: () {
                            navigateAndUpdateComment(context, book.customInfo.comment);
                          },
                          child: book.customInfo.comment.isEmpty
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    border: Border.all(
                                      color: AppColors.gray1,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
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
                                  style: TextStyle(
                                    fontFamily: 'NotoSansKrRegular',
                                    fontSize: 12.0,
                                    color: AppColors.softBlack,
                                  ),
                                ),
                        ),
                        SizedBox(height: 20.0),
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
                            Tab(text: 'NOTE'),
                            Tab(text: 'HIGHLIGHT'),
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
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return BookDetailInfoListViewTile(book: book, index: index);
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return BookDetailNoteListViewTile(book: book);
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return BookDetailHighlightListViewTile(book: book);
                        }),
                  ),
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
