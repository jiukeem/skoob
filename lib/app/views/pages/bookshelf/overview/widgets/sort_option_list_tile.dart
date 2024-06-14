import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:skoob/app/views/pages/bookshelf/overview/widgets/sort_option_bottom_sheet.dart';
import 'package:skoob/app/views/widgets/general_divider.dart';

class SortOptionListTile extends StatefulWidget {
  final int index;
  final SortOption currentSortOption;
  final bool isAscending;

  const SortOptionListTile({super.key, required this.index,
    required this.currentSortOption, required this.isAscending});

  @override
  State<SortOptionListTile> createState() => _SortOptionListTileState();
}

class _SortOptionListTileState extends State<SortOptionListTile> {
  final Map<String, SortOption> labelMap = sortOptionMapBottomSheet;

  @override
  Widget build(BuildContext context) {
    final label = sortOptionMapBottomSheet.keys.toList()[widget.index];
    final isCurrentOption = labelMap[label] == widget.currentSortOption;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () {
          final bool isAscending =  isCurrentOption ? !widget.isAscending : true;
          Navigator.pop(context, {'selectedOption': labelMap[label], 'isAscending': isAscending});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: isCurrentOption
                      ? widget.isAscending ? const Icon(FluentIcons.chevron_up_24_regular) : const Icon(FluentIcons.chevron_down_24_regular)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const GeneralDivider(verticalPadding: 0.0)
          ],
        ),
      ),
    );
  }
}
