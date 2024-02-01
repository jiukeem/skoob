import 'package:flutter/material.dart';
import 'package:skoob/pages/my_bookshelf.dart';
import 'package:skoob/pages/search.dart';
import 'package:skoob/pages/result_list.dart';


void main() => runApp(MaterialApp(
  routes: {
    '/': (context) => Search(),
    '/result': (context) => ResultList(),
    '/bookshelf': (context) => MyBookshelf(),
  },
));


