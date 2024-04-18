import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:skoob/app/controller/book_list_manager.dart';
import 'package:skoob/app/views/pages/intro.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/models/book.dart';
import 'app/models/book/basic_info.dart';
import 'app/models/book/custom_info.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  await Hive.initFlutter();
  Hive.registerAdapter(BookReadingStatusAdapter());
  Hive.registerAdapter(BasicInfoAdapter());
  Hive.registerAdapter(CustomInfoAdapter());
  Hive.registerAdapter(BookAdapter());

  var manager = BookListManager();
  await manager.initBox();

  runApp(MultiProvider(
    providers: [
      Provider<BookListManager>(
        create: (_) => manager,
        dispose: (_, BookListManager manager) => manager.dispose()
      )
    ],
    child: MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.primaryYellow,
        textSelectionTheme: const TextSelectionThemeData(
            selectionHandleColor: AppColors.primaryYellow,
            selectionColor: AppColors.gray2,
            cursorColor: AppColors.gray2),
      ),
      home: const Intro(),
    ),
  ));
}

