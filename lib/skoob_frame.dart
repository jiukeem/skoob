import 'package:flutter/material.dart';
import 'package:skoob/app/views/pages/bookshelf.dart';
import 'package:skoob/app/views/pages/search.dart';
import 'package:skoob/app/views/widgets/custom_nav_bar.dart';

class SkoobFrame extends StatefulWidget {
  const SkoobFrame({super.key});

  @override
  State<SkoobFrame> createState() => _SkoobFrameState();
}

class _SkoobFrameState extends State<SkoobFrame> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    Bookshelf(),
    Search(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentPageIndex,
          children: _pages,
        ),
        bottomNavigationBar: CustomNavBar(
          currentIndex: _currentPageIndex,
          onTap: _onItemTapped,
        ),
      )
    );
  }
}
