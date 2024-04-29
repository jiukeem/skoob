import 'package:hive/hive.dart';

import 'package:skoob/app/models/book/basic_info.dart';
import 'package:skoob/app/models/book/custom_info.dart';


@HiveType(typeId: 0)
class Book extends HiveObject{
  @HiveField(0)
  BasicInfo basicInfo;
  @HiveField(1)
  CustomInfo customInfo;

  Book({required this.basicInfo,required this.customInfo});
}

class BookAdapter extends TypeAdapter<Book> {
  @override
  final typeId = 0; // Ensure that this matches the typeId defined in the @HiveType annotation of Book

  @override
  Book read(BinaryReader reader) {
    final basicInfo = reader.read();
    final customInfo = reader.read();
    return Book(basicInfo: basicInfo, customInfo: customInfo);
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer.write(obj.basicInfo);
    writer.write(obj.customInfo);
  }
}