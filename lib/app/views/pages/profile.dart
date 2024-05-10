import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:skoob/app/models/skoob_user.dart';
import 'package:skoob/app/controller/user_data_manager.dart';
import 'package:skoob/app/views/pages/intro.dart';

import '../../models/book/custom_info.dart';
import '../../utils/app_colors.dart';
import 'friend_search.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final UserDataManager _userDataManager = UserDataManager();
  late TabController _tabController;
  bool _isFriendsTabLoading = true;
  final List<SkoobUser> _friendList = [];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getFriendsData();
  }

  Future<void> _getFriendsData() async {
    final friendsUidList = await _userDataManager.getCurrentFriendsList();
    for (String uid in friendsUidList) {
      final friend = await _userDataManager.getFriendData(uid);
      if (friend != null) {
        _friendList.add(friend);
      }
    }
    setState(() {
      _isFriendsTabLoading = false;
    });
    return;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'MY PAGE',
            style: TextStyle(
              fontFamily: 'LexendExaMedium',
              fontSize: 24.0
          ),),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(FluentIcons.person_add_24_regular),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FriendSearch()));
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildUserProfile(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFriendsTab(),
                Text('feed tab'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<SkoobUser>('userBox').listenable(),
      builder: (context, Box<SkoobUser> box, _) {
        if (box.values.isNotEmpty) {
          SkoobUser user = box.values.first;
          final feedMap = _makeFeedMessage(user);
          return Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 28.0, 14.0),
            child: Row(
              children: [
                _buildUserImage(user.photoUrl),
                const SizedBox(width: 15.0,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: AppColors.softBlack,
                          fontFamily: 'NotoSansKRRegular',
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 4,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              '${feedMap['latestFeedBookTitle']}  ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.softBlack,
                                fontFamily: 'NotoSansKRBold',
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                          // const SizedBox(width: 6.0,),
                          Text(
                            feedMap['latestFeedStatus'],
                            style: const TextStyle(
                              color: AppColors.softBlack,
                              fontFamily: 'NotoSansKRRegular',
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return const Text('No saved user in Hive userBox');
        }
      },
    );
  }

  Widget _buildUserImage(String photoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
          width: 72,
          height: 72,
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

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.softBlack,
      unselectedLabelColor: AppColors.gray2,
      tabs: const [
        Tab(text: 'FRIENDS'),
        Tab(text: 'FEED'),
      ],
      labelStyle: const TextStyle(
        fontFamily: 'LexendMedium',
        fontSize: 16.0,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'LexendLight',
        fontSize: 16.0,
      ),
      indicatorColor: AppColors.primaryGreen,
      dividerHeight: 0.5,
      dividerColor: AppColors.gray2,
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          return Colors.transparent;
        },
      ),
    );
  }

  Map<String, dynamic> _makeFeedMessage(SkoobUser user) {
    final title =  user.latestFeedBookTitle;
    final status = user.latestFeedStatus;

    String verb = '';
    if (status == BookReadingStatus.reading) {
      verb = '읽는 중';
    }
    if (status == BookReadingStatus.done) {
      verb = '완독!';
    }

    String latestFeedTitle = title;
    String latestFeedStatus = verb;

    if (latestFeedTitle.isEmpty || latestFeedStatus.isEmpty) {
      latestFeedTitle = '';
      latestFeedStatus = '';
    }
    return {
      'latestFeedBookTitle': latestFeedTitle,
      'latestFeedStatus': latestFeedStatus
    };
  }

  Widget _buildFriendsTab() {
    return _isFriendsTabLoading
        ? const Expanded(
            child: Center(
              child: SpinKitRotatingCircle(
                size: 30.0,
                color: AppColors.primaryYellow,
              ),
            ),
          )
        : ListView.builder(
            itemCount: _friendList.length,
            itemBuilder: (context, index) {
              final friend = _friendList[index];
              final feedMap = _makeFeedMessage(friend);
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.gray3,
                      width: 1.0
                    ),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(30)
                    ),
                    boxShadow:  [
                      BoxShadow(
                        color: AppColors.gray2.withOpacity(0.8), // Darker shadow for more depth
                        spreadRadius: 0.5,
                        blurRadius: 1,
                        offset: Offset(0, 2), // Vertically lower shadow for a lifted effect
                      ),
                      const BoxShadow(
                        color: AppColors.white, // Soft light from top for a raised effect
                        spreadRadius: 0,
                        blurRadius: 0,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                              width: 54,
                              height: 54,
                              child: friend.photoUrl.isNotEmpty
                                  ? Image.network(
                                      friend.photoUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/temp_logo.png',
                                      fit: BoxFit.cover,
                                    )),
                        ),
                        const SizedBox(width: 16,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                friend.name,
                                style: const TextStyle(
                                  color: AppColors.softBlack,
                                  fontFamily: 'NotoSansKRRegular',
                                  fontSize: 18.0,
                                ),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${feedMap['latestFeedBookTitle']}  ',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.softBlack,
                                        fontFamily: 'NotoSansKRBold',
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(width: 6.0,),
                                  Text(
                                    feedMap['latestFeedStatus'],
                                    style: const TextStyle(
                                      color: AppColors.softBlack,
                                      fontFamily: 'NotoSansKRRegular',
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
  }

  void _logout() {
    _userDataManager.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Intro()),
          (Route<dynamic> route) => false,
    );
  }
}