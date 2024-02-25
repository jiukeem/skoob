import 'package:flutter/material.dart';
import 'package:skoob/app/models/book.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../services/bookshelf_list_tile_mixin.dart';

class AlbumViewListTile extends StatelessWidget with BookshelfListTileMixin {
  AlbumViewListTile({super.key, required Book book}) {
    this.book = book;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}