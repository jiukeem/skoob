import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:skoob/app/models/skoob_user.dart';
import 'package:skoob/app/services/user_service.dart';
import 'package:skoob/app/views/pages/setting/setting.dart';
import '../../../models/book/custom_info.dart';
import '../../../services/third_party/firebase_analytics.dart';
import '../../../utils/app_colors.dart';
import '../bookshelf/overview/bookshelf.dart';
import 'friend_search.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  late TabController _tabController;
  bool _isFriendsTabLoading = true;
  final List<SkoobUser> _friendList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _getFriendsData();
  }

  Future<void> _getFriendsData() async {
    _friendList.clear();
    final friendsList = await _userService.getCurrentFriendsList();
    for (String friendEmail in friendsList) {
      final friend = await _userService.getFriendData(friendEmail);
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
      appBar: _buildAppBar(context),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      surfaceTintColor: AppColors.white,
      backgroundColor: AppColors.white,
      title: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          'MY PAGE',
          style: TextStyle(
              fontFamily: 'LexendExaMedium',
              fontSize: 24.0
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(FluentIcons.person_add_24_regular),
          onPressed: _navigateAndUpdateFriendList,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
          child: IconButton(
              onPressed: () {
                AnalyticsService.logEvent('profile_setting_button_tapped');
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const Setting(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        }
                    )
                );
              },
              icon: const Icon(FluentIcons.settings_24_regular)
          ),
        ),
      ],
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
                _buildUserImage(),
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

  Widget _buildUserImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
          width: 72,
          height: 72,
          child: Image.asset(
            'assets/profile_default.jpg',
            fit: BoxFit.cover,
          )
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.softBlack,
      unselectedLabelColor: AppColors.gray2,
      tabs: const [
        Tab(text: 'FRIENDS'),
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

  Widget _buildFriendsTab() {
    return _isFriendsTabLoading
        ? const Center(
            child: SpinKitRotatingCircle(
              size: 30.0,
              color: AppColors.primaryYellow,
            ),
          )
        : RefreshIndicator(
            color: AppColors.white,
            backgroundColor: AppColors.primaryYellow,
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100.0),
              itemCount: _friendList.length,
              itemBuilder: (context, index) {
                final friend = _friendList[index];
                return _buildFriendTile(friend);
              },
            ),
          );
  }

  Widget _buildFriendTile(SkoobUser friend) {
    final feedMap = _makeFeedMessage(friend);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: InkWell(
        onTap: () {
          _visitFriendBookshelf(friend);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.gray3,
              width: 1.0,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray2.withOpacity(0.8),
                spreadRadius: 0.5,
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
              const BoxShadow(
                color: AppColors.white,
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
                _buildFriendImage(),
                const SizedBox(width: 16,),
                _buildFriendDetails(friend, feedMap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 54,
        height: 54,
        child: Image.asset(
          'assets/profile_default.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFriendDetails(SkoobUser friend, Map<String, dynamic> feedMap) {
    return Expanded(
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
    );
  }

  Map<String, dynamic> _makeFeedMessage(SkoobUser user) {
    final title = user.latestFeedBookTitle;
    final status = user.latestFeedStatus;

    String verb = '';
    if (status == BookReadingStatus.reading) {
      verb = '읽는 중';
    } else if (status == BookReadingStatus.done) {
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

  void _visitFriendBookshelf(SkoobUser friend) {
    AnalyticsService.logEvent('profile_visit_friend', parameters: {
      'visit_to': friend.email
    });
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Bookshelf(isVisiting: true, hostUser: friend)));
  }

  void _navigateAndUpdateFriendList() async {
    AnalyticsService.logEvent('profile_button_tapped_friend_search');
    final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FriendSearch()));

    if (result != null) {
      await _getFriendsData();
      setState(() {});
    }
  }

  Future<void> _handleRefresh() async {
    AnalyticsService.logEvent('profile_refresh_friend_tab');
    _friendList.clear();
    await _getFriendsData();
  }
}