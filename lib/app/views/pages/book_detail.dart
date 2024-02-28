import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Book book = widget.book;
    final int itemCount = book.basicInfo.translator.isEmpty ? 8 : 9;
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
                          Text(
                            '국민의 모든 자유와 권리는 국가안전보장·질서유지 또는 공공복리를 위하여 필요한 경우에 한하여 법률로써 제한할 수 있으며, 제한하는 경우에도 자유와 권리의 본질적인 내용을 침해할 수 없다.',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'NotoSansKrLight',
                              fontSize: 12.0,
                              color: AppColors.softBlack,
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
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListView.builder(
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        return BookDetailInfoListViewTile(book: book, index: index);
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return BookDetailNoteListViewTile(book: book);
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListView.builder(
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
