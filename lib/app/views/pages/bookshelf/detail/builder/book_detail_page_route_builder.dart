import 'package:flutter/cupertino.dart';

import '../../../../../models/book.dart';
import '../book_detail.dart';

PageRouteBuilder buildBookDetailPageRoute(Book book) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => BookDetail(book: book),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      });
}