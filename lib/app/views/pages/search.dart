import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/aladin.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:skoob/app/controller/shared_list_state.dart';
import 'package:provider/provider.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/widgets/search_result_view_list_tile.dart';

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
    items.forEach((item) {
      var book = _setBookConfiguration(item);
      _searchResults.add(book);
    });
  }

  Book _setBookConfiguration(dynamic item) {
    return Book(
      title: item['title'],
      author: item['author'],
      publisher: item['publisher'],
      pubDate: item['pubDate'],
      description: item['description'],
      coverImageUrl: item['cover'],
      infoUrl: item['link'],
      category: item['categoryName'],
      isbn10: item['isbn'],
      isbn13: item['isbn13'],
    );
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
      height: 60.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
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
                ),
              )),
          const SizedBox(width: 2.0),
          IconButton(
              onPressed: () {
                setState(() {
                  _searchKeyword = _searchController.text;
                  _startSearch();
                });
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