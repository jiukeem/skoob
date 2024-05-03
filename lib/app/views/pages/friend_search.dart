import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skoob/app/models/skoob_user.dart';

import '../../controller/user_data_manager.dart';
import '../../utils/app_colors.dart';

class FriendSearch extends StatefulWidget {
  const FriendSearch({super.key});

  @override
  State<FriendSearch> createState() => _FriendSearchState();
}

class _FriendSearchState extends State<FriendSearch> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  final UserDataManager _userDataManager = UserDataManager();
  bool _isLoading = false;
  SkoobUser? _resultUser;

  Future<void> _startSearch() async {
    print('searchKeyword: $_searchKeyword');
    setState(() {
      _isLoading = true;
    });
    _resultUser = await _userDataManager.searchUserByEmail(_searchKeyword);
    setState(() {
      print('resultUser: $_resultUser');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchField(),
            _isLoading
            ? const Expanded(
              child: Center(
                child: SpinKitRotatingCircle(
                  size: 30.0,
                  color: AppColors.primaryYellow,
                ),
              ),
            )
            : _buildSearchResult()
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

  Widget _buildSearchResult() {
    if (_resultUser == null) {
      return const Text('사용자를 찾을 수 없습니다.');
    } else {
      return Text(_resultUser!.name);
    }
  }
}