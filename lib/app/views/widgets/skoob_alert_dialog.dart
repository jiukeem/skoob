import 'package:flutter/material.dart';
import 'package:skoob/app/utils/app_colors.dart';

Future<bool?> buildAlertDialog({
  required BuildContext context,
  required String contentText,
  required List<Widget> actions,
  String? titleText,
  bool barrierDismissible = true,
}) async {
  AlertDialog alert = AlertDialog(
    backgroundColor: AppColors.white,
    surfaceTintColor: AppColors.white,
    title: titleText != null ? Text(
      titleText,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'NotoSansKRBold',
        fontSize: 16.0,
        color: AppColors.softBlack,
      ),
    ) : null,
    content: Text(contentText),
    actions: actions,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
  );

  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return alert;
    },
  );
}

Widget buildDialogButton({
  required String text,
  required Color backgroundColor,
  required Color textColor,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        color: backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'NotoSansKRMedium',
            fontSize: 14.0,
            color: textColor,
          ),
        ),
      ),
    ),
  );
}