import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class BasicInfo {
  @HiveField(0)
  String title;
  @HiveField(1)
  String author;
  @HiveField(2)
  String publisher;
  @HiveField(3)
  String pubDate;
  @HiveField(4)
  String description;
  @HiveField(5)
  String coverImageUrl;
  @HiveField(6)
  String infoUrl;
  @HiveField(7)
  String category;
  @HiveField(8)
  String isbn13;
  @HiveField(9)
  String isbn10;
  @HiveField(10)
  String translator;

  BasicInfo({
    required this.title,
    required this.author,
    required this.publisher,
    required this.pubDate,
    required this.description,
    required this.coverImageUrl,
    required this.infoUrl,
    required this.category,
    required this.isbn13,
    required this.isbn10,
    this.translator = '',
  });
}

class BasicInfoAdapter extends TypeAdapter<BasicInfo> {
  @override
  final typeId = 1;

  @override
  BasicInfo read(BinaryReader reader) {
    return BasicInfo(
      title: reader.readString(),
      author: reader.readString(),
      publisher: reader.readString(),
      pubDate: reader.readString(),
      description: reader.readString(),
      coverImageUrl: reader.readString(),
      infoUrl: reader.readString(),
      category: reader.readString(),
      isbn13: reader.readString(),
      isbn10: reader.readString(),
      translator: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, BasicInfo obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.author);
    writer.writeString(obj.publisher);
    writer.writeString(obj.pubDate);
    writer.writeString(obj.description);
    writer.writeString(obj.coverImageUrl);
    writer.writeString(obj.infoUrl);
    writer.writeString(obj.category);
    writer.writeString(obj.isbn13);
    writer.writeString(obj.isbn10);
    writer.writeString(obj.translator);
  }
}