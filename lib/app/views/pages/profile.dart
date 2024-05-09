import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:skoob/app/models/skoob_user.dart';
import 'package:skoob/app/controller/user_data_manager.dart';
import 'package:skoob/app/views/pages/intro.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              children: const [
                Text('friends tab'),
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
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
                      const Text(
                        '\'몸은 기억한다\' 읽는 중',
                        style: TextStyle(
                          color: AppColors.softBlack,
                          fontFamily: 'NotoSansKRRegular',
                          fontSize: 14.0,
                        ),
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
    );
  }

  void _logout() {
    _userDataManager.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Intro()),
          (Route<dynamic> route) => false,
    );
  }
}