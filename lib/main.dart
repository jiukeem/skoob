import 'package:flutter/material.dart';
import 'package:skoob/app/views/pages/bookshelf.dart';
import 'package:skoob/app/views/pages/search.dart';
import 'package:skoob/app/views/widgets/skoob_bottom_nav_bar.dart';
import 'package:skoob/app/utils/app_colors.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    primaryColor: AppColors.primaryYellow, // Used for the AppBar and other primary color areas.
  ),
  home: Skoob(),
)
);

class Skoob extends StatefulWidget {
  const Skoob({super.key});

  @override
  State<Skoob> createState() => _SkoobState();
}

class _SkoobState extends State<Skoob> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    Search(),
    Search(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPageIndex,
        children: _pages,
      ),
      bottomNavigationBar: SkoobBottomNavBar(
        currentIndex: _currentPageIndex,
        onTap: _onItemTapped
      ),
    );
  }
}
