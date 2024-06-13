import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skoob/app/services/third_party/firebase_analytics.dart';

import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/bookshelf/overview/bookshelf.dart';
import 'package:skoob/app/views/pages/social/profile.dart';
import 'package:skoob/app/views/pages/search/search.dart';
import 'package:skoob/app/views/pages/home/skoob_bottom_nav_bar.dart';

class Skoob extends StatefulWidget {
  const Skoob({super.key});

  @override
  State<Skoob> createState() => _SkoobState();
}

class _SkoobState extends State<Skoob> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    const Bookshelf(),
    const Search(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.logEvent(
        'skoob_initState',
        parameters: {}
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      AnalyticsService.logEvent('skoob_page_index_changed',
          parameters: {'index_from': _currentPageIndex, 'index_to': index});
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressed;

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final backButtonHasNotBeenPressedOrSnackbarHasBeenClosed = lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 3);

        if (backButtonHasNotBeenPressedOrSnackbarHasBeenClosed) {
          lastPressed = now;
          Fluttertoast.showToast(
            msg: '뒤로 가기를 한 번 더 누르시면 앱이 종료됩니다',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: AppColors.gray1,
            textColor: AppColors.white,
            fontSize: 14.0,
          );
          return false; // false will cancel the back button event
        }

        AnalyticsService.logEvent('skoob_exit_app_by_back_button');
        return true; // true will exit the app
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: _currentPageIndex,
                  children: _pages,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SkoobBottomNavBar(
                    currentIndex: _currentPageIndex,
                    onTap: _onItemTapped
                ),
              )
            ]
        ),
      ),
    );
  }
}