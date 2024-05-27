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
  String photoUrl;
  @HiveField(4)
  String phoneNumber;
  @HiveField(5)
  String latestFeedBookTitle;
  @HiveField(6)
  BookReadingStatus latestFeedStatus;
  @HiveField(7)
  String messageToken;

  SkoobUser(
      {required this.uid,
      required this.name,
      required this.email,
      this.photoUrl = '',
      this.phoneNumber = '',
      this.latestFeedBookTitle = '',
      this.latestFeedStatus = BookReadingStatus.initial,
      required this.messageToken}
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
        photoUrl: map['photoUrl'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
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
    print('Starting to read SkoobUser');
    try {
      var uid = reader.readString();
      print('uid: $uid');
      var name = reader.readString();
      print('name: $name');
      var email = reader.readString();
      print('email: $email');
      var latestFeedBookTitle = reader.readString();
      print('latestFeedBookTitle: $latestFeedBookTitle');
      int latestFeedStatusIndex = reader.readByte(); // Should read as byte
      var latestFeedStatus = BookReadingStatus.values[latestFeedStatusIndex];
      var messageToken = reader.readString();
      print('messageToken: $messageToken');
      print('Read SkoobUser successfully');
      return SkoobUser(
          uid: uid,
          name: name,
          email: email,
          latestFeedBookTitle: latestFeedBookTitle,
          latestFeedStatus: latestFeedStatus,
          messageToken: messageToken
      );
    } catch (e) {
      print('Failed to read SkoobUser: $e');
      rethrow;
    }
  }

  @override
  void write(BinaryWriter writer, SkoobUser obj) {
    writer.writeString(obj.uid);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.phoneNumber);
    writer.writeString(obj.photoUrl);
    writer.writeString(obj.latestFeedBookTitle);
    writer.writeByte(obj.latestFeedStatus.index);
    writer.writeString(obj.messageToken);
  }}