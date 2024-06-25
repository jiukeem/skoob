import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils/app_colors.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String description;

  const ExpandableTextWidget({super.key, required this.description});

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          description,
          maxLines: _isExpanded ? null : 3,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 14.0,
              fontFamily: 'NotoSansKRRegular',
              color: AppColors.softBlack,

          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          splashColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  '더보기',
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'NotoSansKRRegular',
                      color: AppColors.gray1
                  ),
                ),
                Icon(
                  _isExpanded ? FluentIcons.chevron_up_20_regular : FluentIcons.chevron_down_20_regular,
                  color: AppColors.gray1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
