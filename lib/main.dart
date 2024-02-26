import 'package:flutter/material.dart';
import 'package:skoob/app/controller/shared_list_state.dart';
import 'package:skoob/app/views/pages/bookshelf.dart';
import 'package:skoob/app/views/pages/search.dart';
import 'package:skoob/app/views/widgets/skoob_bottom_nav_bar.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:provider/provider.dart';

void main() => runApp(ChangeNotifierProvider(
    create: (context) => SharedListState(),
    child: MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.primaryYellow,
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: AppColors.primaryYellow,
          selectionColor: AppColors.gray2,
          cursorColor: AppColors.gray2
        ),
      ),
      home: const Skoob(),
    )));

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
