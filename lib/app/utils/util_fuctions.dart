import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/book.dart';

String getCurrentDateAsString() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy.MM.dd');
  final String formattedDate = formatter.format(now);
  return formattedDate;
}

String getCurrentDateAndTimeAsString() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy.MM.dd HH:mm:ss');
  final String formattedDate = formatter.format(now);
  return formattedDate;
}

String dateTimeToString(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy.MM.dd');
  final String formattedDate = formatter.format(dateTime);
  return formattedDate;
}

Map<String, String> createMapFromSkoobBook(Book book) {
  return {
    'title': book.basicInfo.title,
    'author': book.basicInfo.author,
    'publisher': book.basicInfo.publisher,
    'pubDate': book.basicInfo.pubDate,
    'description': book.basicInfo.description,
    'coverImageUrl': book.basicInfo.coverImageUrl,
    'infoUrl': book.basicInfo.infoUrl,
    'category': book.basicInfo.category,
    'isbn13': book.basicInfo.isbn13,
    'isbn10': book.basicInfo.isbn10,
    'translator': book.basicInfo.translator,
    'addedDate': book.customInfo.addedDate,
    'status': book.customInfo.status.toString(),
    'startReadingDate': book.customInfo.startReadingDate,
    'finishReadingDate': book.customInfo.finishReadingDate,
    'rate': book.customInfo.rate,
    'comment': book.customInfo.comment,
  };
}

bool isDocumentDataValid(DocumentSnapshot? doc) {
  return doc != null && doc.data() != null;
}