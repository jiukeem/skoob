import 'package:flutter/material.dart';
import 'package:skoob/app/controller/shared_list_state.dart';
import 'package:skoob/skoob_frame.dart';
import 'package:provider/provider.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    primaryColor: AppColors.primaryYellow, // Used for the AppBar and other primary color areas.
  ),
  home: Skoob(),
)
);