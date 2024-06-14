import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/aladin.dart';
import 'package:skoob/app/models/book/basic_info.dart';
import 'package:skoob/app/models/book/custom_info.dart';
import 'package:skoob/app/services/third_party/firebase_analytics.dart';
import 'package:skoob/app/utils/util_fuctions.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/search/widgets/search_result_view_list_tile.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  SearchStatus _currentStatus = SearchStatus.initial;
  final List<Book> _searchResults = [];
  Aladin aladin = Aladin();

  void _startSearch() {
    if (_searchKeyword.isEmpty) return;

    setState(() {
      _currentStatus = SearchStatus.loading;
    });
    _searchBookByTitle();
  }

  Future<void> _searchBookByTitle() async {
    AnalyticsService.logEvent('search_start_search', parameters: {
      'query': _searchKeyword
    });
    Uri url = Uri.parse(aladin.requestUrl);
    Map<String, dynamic> queryParams = {
      'TTBKey': aladin.ttb_key,
      'Query': _searchKeyword,
      'Output': 'JS',
      'Version': '20131101',
      'Cover': 'Big',
      'MaxResults': '50',
      'Start': '1',
    };
    Uri uri = Uri.https(url.authority, url.path, queryParams);

    Response response = await get(uri);
    if (response.statusCode == 200) {
      _setSearchResults(response);
      setState(() {
        _currentStatus = SearchStatus.results;
      });
    } else {
      setState(() {
        _currentStatus = SearchStatus.error;
      });
    }
  }

  void _setSearchResults(Response rawResponse) {
    _searchResults.clear();

    Map<String, dynamic> result = jsonDecode(rawResponse.body);
    List<dynamic> items = result['item'];
    for (var item in items) {
      var book = _setBookConfiguration(item);
      _searchResults.add(book);
    }
  }

  Book _setBookConfiguration(dynamic item) {
    final result = parseJsonDataToAuthorAndTranslator(item['author'].toString());

    return Book(
        basicInfo: BasicInfo(
            title: item['title'],
            author: result['author'] ?? '',
            translator: result['translator'] ?? '',
            publisher: item['publisher'],
            pubDate: item['pubDate'].toString().replaceAll('-', '.'),
            description: item['description'],
            coverImageUrl: item['cover'],
            infoUrl: item['link'],
            category: item['categoryName'],
            isbn10: item['isbn'],
            isbn13: item['isbn13']),
        customInfo: CustomInfo(addedDate: getCurrentDateAsString()));
  }

  Map<String, String> parseJsonDataToAuthorAndTranslator(String data) {
    List<String> parts = data.split(',');
    List<String> authors = [];
    String translator = '';

    for (String part in parts) {
      String trimmedPart = part.trim();
      if (trimmedPart.contains('(옮긴이)')) {
        translator = trimmedPart.replaceAll('(옮긴이)', '').trim();
      } else {
        authors.add(trimmedPart.replaceAll('(지은이)', '').trim());
      }
    }
    return {
      'author': authors.join(', '),
      'translator': translator
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildSearchAppBar(),
          _buildSearchField(),
          _buildContentBasedOnSearchStatus(),
        ],
      ),
    );
  }

  Widget _buildSearchAppBar() {
    return const SizedBox(
      height: 56.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'SEARCH',
              style: TextStyle(
                  fontFamily: 'LexendExaMedium',
                  fontSize: 24.0
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 10.0, 12.0),
      child: Row(
        children: [
          Expanded(
              child: Container(
                // height: 40.0,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  color: AppColors.gray3
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    isDense: true,
                  ),
                  cursorWidth: 1.2,
                  style: const TextStyle(
                    fontSize: 16.0
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _searchKeyword = _searchController.text;
                      _startSearch();
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              )),
          const SizedBox(width: 2.0),
          IconButton(
              onPressed: () {
                setState(() {
                  _searchKeyword = _searchController.text;
                  _startSearch();
                });
                FocusScope.of(context).requestFocus(FocusNode());
              },
              icon: const Icon(FluentIcons.search_24_regular)
          )
        ],
      ),
    );
  }

  Widget _buildContentBasedOnSearchStatus() {
    switch (_currentStatus) {
      case SearchStatus.initial:
        return const Expanded(
          child: Center(
            child: Text('책 이름으로 검색해보세요'),
          ),
        );
      case SearchStatus.loading:
        return const Expanded(
          child: Center(
            child: SpinKitRotatingCircle(
              size: 30.0,
              color: AppColors.primaryYellow,
            ),
          ),
        );
      case SearchStatus.results:
        return Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              Book book = _searchResults[index];
              return SearchResultViewListTile(book: book);
            }
          ),
        );
      case SearchStatus.error:
        return Column(
          children: [
            const Text('SearchStatus is error'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStatus = SearchStatus.loading;
                      _searchBookByTitle();
                    });
                  },
                  child: const Text('Retry')),
            ),
          ],
        );
      default:
        print(
            'WARNING: Encountered an unexpected search status: $_currentStatus in search.dart');
        return const Text('SearchStatus is unknown');
    }
  }
}

enum SearchStatus { initial, loading, results, error }