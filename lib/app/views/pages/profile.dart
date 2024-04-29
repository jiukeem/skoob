import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:skoob/app/models/skoob_user.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
          ],
        )
    );
  }

  Widget _buildProfileAppBar() {
    return const SizedBox(
      height: 60.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'PROFILE',
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

  Widget _buildUserImage(String photoUrl) {
    if (photoUrl.isNotEmpty) {
      return Image.network(photoUrl, fit: BoxFit.cover);
    } else {
      return Image.asset('assets/temp_logo.png', fit: BoxFit.cover, height: 150,);
    }
  }
}
