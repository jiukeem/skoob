import 'package:hive/hive.dart';

import 'book/custom_info.dart';

@HiveType(typeId: 4)
class SkoobUser extends HiveObject {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  String latestFeedBookTitle;
  @HiveField(4)
  BookReadingStatus latestFeedStatus;
  @HiveField(5)
  String messageToken;

  SkoobUser(
      {required this.uid,
      required this.name,
      required this.email,
      this.latestFeedBookTitle = '',
      this.latestFeedStatus = BookReadingStatus.initial,
      required this.messageToken}
  );

  Map<String, String> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'latestFeedBookTitle': latestFeedBookTitle,
      'latestFeedStatus': latestFeedStatus.toString(),
      'messageToken': messageToken,
    };
  }

  static final Map<String, BookReadingStatus> statusMap = {
    "BookReadingStatus.initial": BookReadingStatus.initial,
    "BookReadingStatus.notStarted": BookReadingStatus.notStarted,
    "BookReadingStatus.reading": BookReadingStatus.reading,
    "BookReadingStatus.done": BookReadingStatus.done,
  };

  static SkoobUser fromMap(Map<String, dynamic> map) {
    String statusString = map['latestFeedStatus'] as String? ?? 'BookReadingStatus.initial';
    BookReadingStatus status = statusMap[statusString] ?? BookReadingStatus.initial;
    return SkoobUser(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        latestFeedBookTitle: map['latestFeedBookTitle'] ?? '',
        latestFeedStatus: status,
        messageToken: map['messageToken'],
    );
  }
}

class UserAdapter extends TypeAdapter<SkoobUser> {
  @override
  final typeId = 4;

  @override
  SkoobUser read(BinaryReader reader) {
    return SkoobUser(
        uid: reader.readString(),
        name: reader.readString(),
        email: reader.readString(),
        latestFeedBookTitle: reader.readString(),
        latestFeedStatus: reader.read(),
        messageToken: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, SkoobUser obj) {
    writer.writeString(obj.uid);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.latestFeedBookTitle);
    writer.write(obj.latestFeedStatus);
    writer.write(obj.messageToken);
  }}