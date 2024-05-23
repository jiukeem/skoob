import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final UserDataManager _userDataManager = UserDataManager();
  String _searchKeyword = '';
  bool _isLoading = false;
  bool _isFriend = false;
  SkoobUser? _resultUser;
  List<String> _currentFriendsList = [];


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
  void initState() {
    super.initState();
    _getCurrentFriendsList();
  }

  void _getCurrentFriendsList() async {
    _currentFriendsList = await _userDataManager.getCurrentFriendsList();
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
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 8.0, 12.0),
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
      _checkAlreadyFriend();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // _buildUserImage(_resultUser!.photoUrl),
                // TODO
                const SizedBox(width: 15.0,),
                Text(
                  _resultUser!.name,
                  style: const TextStyle(
                    color: AppColors.softBlack,
                    fontFamily: 'NotoSansKRBold',
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            IconButton(
                onPressed: () async {
                  if (!_isFriend) {
                    await _userDataManager.addFriend(_resultUser!);
                    Fluttertoast.showToast(
                      msg: '친구를 추가하였습니다',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 1,
                      backgroundColor: AppColors.gray1,
                      textColor: AppColors.white,
                      fontSize: 14.0,
                    );
                    setState(() {
                      _isFriend = true;
                    });
                    return;
                  }
                  if (_isFriend) {
                    Fluttertoast.showToast(
                      msg: '이미 추가된 사용자입니다',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 1,
                      backgroundColor: AppColors.gray1,
                      textColor: AppColors.white,
                      fontSize: 14.0,
                    );
                  }
                },
                icon: _isFriend
                    ? const Icon(FluentIcons.person_add_24_filled)
                    : const Icon(FluentIcons.person_add_24_regular)
            )
          ],
        ),
      );
    }
  }

  Widget _buildUserImage(String photoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
          width: 40,
          height: 40,
          child: photoUrl.isNotEmpty
              ? Image.network(
            photoUrl,
            fit: BoxFit.cover,
          )
              : Image.asset(
            'assets/temp_logo.png',
            fit: BoxFit.cover,
          )),
    );
  }

  void _checkAlreadyFriend() {
    if (_resultUser == null) {
      return;
    }

    final targetUid = _resultUser!.uid;

    if (_userDataManager.currentUser?.uid == targetUid) {
      _isFriend = true;
      return;
    }

    for (String friendUid in _currentFriendsList) {
      print('friendUid: $friendUid');
      if (friendUid == targetUid) {
        _isFriend = true;
        return;
      }
    }
    _isFriend = false;
  }
}
