import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

import '../../../models/book.dart';
import '../../../services/book_service.dart';
import '../../../services/third_party/firebase_analytics.dart';
import '../../../utils/app_colors.dart';
import '../bookshelf/detail/widgets/info/book_detail_info_list_view_tile.dart';

class SearchDetail extends StatefulWidget {
  final Book book;

  const SearchDetail({super.key, required this.book});

  @override
  State<SearchDetail> createState() => _SearchDetailState();
}

class _SearchDetailState extends State<SearchDetail> {
  final BookService _bookService = BookService();

  void _addBookToBookshelf(Book book) {
    _bookService.saveBook(book);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
      ),
      body: Column(
        children: [
          _buildBookCoverAndTitle(book),
          const GeneralDivider(verticalPadding: 0),
          _buildBookInfo(book),
          _buildAddBookButton(book),
        ],
      ),
    );
  }

  Widget _buildBookCoverAndTitle(Book book) {
    return Padding(
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
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            book.basicInfo.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoSansKRMedium',
              fontSize: 18.0,
              color: AppColors.softBlack,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            book.basicInfo.author,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoSansKRRegular',
              fontSize: 16.0,
              color: AppColors.gray1,
            ),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildBookInfo(Book book) {
    List<String> infoLabelList = [
      'Introduction',
      'Publisher',
      'Publish Date',
      'Category',
      // 'Link',
    ];

    if (book.basicInfo.translator.isNotEmpty) {
      infoLabelList.add('Translator');
    }

    return Flexible(
      child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          itemCount: infoLabelList.length,
          itemBuilder: (context, index) {
            return BookDetailInfoListViewTile(book: book, index: index, labels: infoLabelList,);
          }),
    );
  }

  Widget _buildAddBookButton(Book book) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              AnalyticsService.logEvent('search_detail_add_book', parameters: {
                'title': book.basicInfo.title,
              });
              _addBookToBookshelf(book);
              Fluttertoast.showToast(
                msg: '책을 추가하였습니다: ${book.basicInfo.title}',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: AppColors.gray1,
                textColor: AppColors.white,
                fontSize: 14.0,
              );
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)
                )
              ),
              backgroundColor: WidgetStateProperty.all(AppColors.primaryGreen),
            ),
            child: const Text(
              '책장에 추가하기',
              style: TextStyle(
                color: AppColors.white,
                fontFamily: 'NotoSansKRBold',
                fontSize: 14.0
              ),
            ),
          ),
        ),
      ),
    );
  }
}


