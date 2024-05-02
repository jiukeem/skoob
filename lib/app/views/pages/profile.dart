import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:skoob/app/models/skoob_user.dart';
import 'package:skoob/app/controller/user_data_manager.dart';
import 'package:skoob/app/views/pages/intro.dart';

import 'friend_search.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserDataManager _userDataManager = UserDataManager();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
          children: [
            _buildProfileAppBar(),
            ValueListenableBuilder(
              valueListenable: Hive.box<SkoobUser>('userBox').listenable(),
              builder: (context, Box<SkoobUser> box, _) {
                if (box.values.isNotEmpty) {
                  SkoobUser user = box.values.first;
                  return Column(
                    children: [
                      Row(
                        children: [
                          _buildUserImage(user.photoUrl),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name
                              ),
                              Text(
                                '\'몸은 기억한다\' 읽는 중'
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  );
                } else {
                  return Text('no saved user in Hive userBox');
                }
              },
            ),
            ElevatedButton(onPressed: () {_logout();}, child: Text('로그아웃')),
          ],
        )
    );
  }

  Widget _buildProfileAppBar() {
    return SizedBox(
      height: 60.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'PROFILE',
              style: TextStyle(
                  fontFamily: 'LexendExaMedium',
                  fontSize: 24.0
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => FriendSearch()));
                },
                icon: const Icon(FluentIcons.person_add_24_regular)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserImage(String photoUrl) {
    if (photoUrl.isNotEmpty) {
      return Image.network(photoUrl, fit: BoxFit.cover);
    } else {
      return Image.asset('assets/temp_logo.png', fit: BoxFit.cover, height: 150,);
    }
  }

  void _logout() {
    _userDataManager.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Intro()),
          (Route<dynamic> route) => false,
    );
  }
}
