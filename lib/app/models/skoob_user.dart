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
  final String photoUrl;
  @HiveField(4)
  final String phoneNumber;
  @HiveField(5)
  String latestFeedBookTitle;
  @HiveField(6)
  BookReadingStatus latestFeedStatus;

  SkoobUser(
      {required this.uid,
      required this.name,
      required this.email,
      required this.photoUrl,
      required this.phoneNumber,
      required this.latestFeedBookTitle,
      required this.latestFeedStatus}
  );

  Map<String, String> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'latestFeedBookTitle': latestFeedBookTitle,
      'latestFeedStatus': latestFeedStatus.toString(),
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
        photoUrl: map['photoUrl'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
        latestFeedBookTitle: map['latestFeedBookTitle'] ?? '',
        latestFeedStatus: status,
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
        photoUrl: reader.readString(),
        phoneNumber: reader.readString(),
        latestFeedBookTitle: reader.readString(),
        latestFeedStatus: reader.read()
    );
  }

  @override
  void write(BinaryWriter writer, SkoobUser obj) {
    writer.writeString(obj.uid);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.phoneNumber);
    writer.writeString(obj.photoUrl);
    writer.writeString(obj.latestFeedBookTitle);
    writer.write(obj.latestFeedStatus);
  }}