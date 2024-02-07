import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;


  CustomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navBarItem(0, 'Bookshelf'),
          navBarItem(1, 'Search'),
        ],
      ),
    );
  }

  Widget navBarItem(int index, String label) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.blueGrey[900] : Colors.grey[300],
          fontWeight: FontWeight.w500,
          fontSize: 18.0,
        ),
      ),
    );
  }
}
