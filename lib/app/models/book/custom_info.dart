import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class CustomInfo {
  @HiveField(0)
  String addedDate;
  @HiveField(1)
  BookReadingStatus status;
  @HiveField(2)
  String startReadingDate;
  @HiveField(3)
  String finishReadingDate;
  @HiveField(4)
  String rate;
  @HiveField(5)
  String comment;

  CustomInfo({
    required this.addedDate,
    this.status = BookReadingStatus.initial,
    this.startReadingDate = '',
    this.finishReadingDate = '',
    this.rate = '',
    this.comment = '',
  });

  static final Map<String, BookReadingStatus> statusMap = {
    "BookReadingStatus.initial": BookReadingStatus.initial,
    "BookReadingStatus.notStarted": BookReadingStatus.notStarted,
    "BookReadingStatus.reading": BookReadingStatus.reading,
    "BookReadingStatus.done": BookReadingStatus.done,
  };

  static CustomInfo fromMap(Map<String, dynamic> map) {
    print("Creating CustomInfo from map: $map");
    String statusString = map['status'] as String? ?? 'BookReadingStatus.initial'; // Default to 'initial' if null
    BookReadingStatus status = statusMap[statusString] ?? BookReadingStatus.initial;
    return CustomInfo(
      addedDate: map['addedDate'] ?? '',
      status: status,
      startReadingDate: map['startReadingDate'] ?? '',
      finishReadingDate: map['finishReadingDate'] ?? '',
      rate: map['rate'] ?? '',
      comment: map['comment'] ?? '',
    );
  }
}

class CustomInfoAdapter extends TypeAdapter<CustomInfo> {
  @override
  final typeId = 2;

  @override
  CustomInfo read(BinaryReader reader) {
    return CustomInfo(
      addedDate: reader.readString(),
      status: reader.read(),  // Automatically uses BookReadingStatusAdapter
      startReadingDate: reader.readString(),
      finishReadingDate: reader.readString(),
      rate: reader.readString(),
      comment: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, CustomInfo obj) {
    writer.writeString(obj.addedDate);
    writer.write(obj.status);  // Automatically uses BookReadingStatusAdapter
    writer.writeString(obj.startReadingDate);
    writer.writeString(obj.finishReadingDate);
    writer.writeString(obj.rate);
    writer.writeString(obj.comment);
  }
}

enum BookReadingStatus { initial, notStarted, reading, done }

@HiveType(typeId: 3)
class BookReadingStatusAdapter extends TypeAdapter<BookReadingStatus> {
  @override
  final typeId = 3;

  @override
  BookReadingStatus read(BinaryReader reader) {
    return BookReadingStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, BookReadingStatus obj) {
    writer.writeByte(obj.index);
  }
}