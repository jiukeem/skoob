import 'package:flutter/material.dart';
import 'package:skoob/app/views/pages/bookshelf.dart';
import 'package:skoob/app/views/pages/search.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => Home(),
    '/bookshelf': (context) => Bookshelf(),
    '/search': (context) => Search(),
  },
));

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 60.0,
        backgroundColor: Colors.white,
        indicatorShape: CircleBorder(),
        surfaceTintColor: Colors.white,
        destinations: [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'bookshelf'),
          NavigationDestination(icon: Icon(Icons.search), label: 'search'),
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      body: [
        Bookshelf(),
        Search(),
      ][currentPageIndex],
    );
  }
}


