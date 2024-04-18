import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../widgets/skoob_bottom_nav_bar.dart';
import 'bookshelf.dart';
import 'search.dart';

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
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}