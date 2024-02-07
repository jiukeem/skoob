import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/models/aladin.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  SearchStatus _currentStatus = SearchStatus.initial;
  List<Book> _searchResults = [];
  Aladin aladin = Aladin();

  void _startSearch() {
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildContentBasedOnSearchStatus(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentBasedOnSearchStatus() {
    switch (_currentStatus) {
      case SearchStatus.initial:
        return [
          SizedBox(
            height: 40.0,
            width: 250.0,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
                labelText: 'book title',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchKeyword = _searchController.text;
                  _startSearch();
                });
              },
              child: Text('Search'),
            ),
          )
        ];
      case SearchStatus.loading:
        return [
          SpinKitRotatingCircle(
            size: 30.0,
            color: Colors.purple[100],
          )
        ];
      case SearchStatus.results:
        return [
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                Book book = _searchResults[index];
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
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // add to my bookshelf
                    },
                  ),
                );
              },
            ),
          )
        ];
      case SearchStatus.error:
        return [
          Text('SearchStatus is error'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStatus = SearchStatus.loading;
                  _searchBookByTitle();
                });
              },
              child: Text('Retry')
            ),
          ),
        ];
      default:
        print('WARNING: Encountered an unexpected search status: $_currentStatus in search.dart');
        return [
          Text('SearchStatus is unknown')
        ];
    }
  }
}

enum SearchStatus { initial, loading, results, error }