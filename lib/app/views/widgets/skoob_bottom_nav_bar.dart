import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:skoob/app/utils/app_colors.dart';

class SkoobBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  SkoobBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28.0, 0, 28.0, 20.0),
      height: 52.0,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        border: Border.all(
          color: AppColors.gray3,
          width: 0.8
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softBlack.withOpacity(0.1), // Shadow color
            spreadRadius: 0,
            blurRadius: 2, // Shadow blur radius
            offset: Offset(0, 2), // Shadow position
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        child: BottomAppBar(
          surfaceTintColor: AppColors.white,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              navBarItem(
                  index: 0,
                  defaultIcon: const Icon(
                      FluentIcons.library_24_regular,
                      color: AppColors.softBlack,
                  ),
                  selectedIcon: const Icon(
                      FluentIcons.library_24_filled,
                      color: AppColors.white,
                  )
              ),
              navBarItem(
                  index: 1,
                  defaultIcon: const Icon(
                      FluentIcons.book_search_24_regular,
                      color: AppColors.softBlack,
                  ),
                  selectedIcon: const Icon(
                      FluentIcons.book_search_24_filled,
                      color: AppColors.white,
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget navBarItem({required int index, required Icon defaultIcon, required Icon selectedIcon}) {
    bool isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        height: 35.0,
        width: 35.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primaryYellow : AppColors.white,
        ),
        child: isSelected ? selectedIcon : defaultIcon
      ),
    );
  }
}