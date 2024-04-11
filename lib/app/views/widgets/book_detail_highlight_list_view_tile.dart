import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class BookDetailHighlightListViewTile extends StatefulWidget {
  final MapEntry highlight;

  const BookDetailHighlightListViewTile({super.key, required this.highlight});

  @override
  State<BookDetailHighlightListViewTile> createState() => _BookDetailHighlightListViewTileState();
}

class _BookDetailHighlightListViewTileState extends State<BookDetailHighlightListViewTile> {
  @override
  Widget build(BuildContext context) {
    final String date = widget.highlight.key.toString().substring(0, 16);
    final String text = widget.highlight.value['text'] ?? '';
    final List<String> images = widget.highlight.value['images'] ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'NotoSansKRRegular',
              fontSize: 13.0,
              color: AppColors.gray1
            ),
          ),
          const SizedBox(height: 4.0,),
          if (images.isNotEmpty)
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: Image.file(File(images[index])),
                );
              }
            ),
          if (text.isNotEmpty)
            Text(
              text,
              style: const TextStyle(
                  fontFamily: 'NotoSansKRRegular',
                  fontSize: 14.0,
                  color: AppColors.softBlack
              ),
            ),
          const SizedBox(height: 20.0,)
        ],
      ),
    );
  }
}
