import 'package:hive/hive.dart';

import 'book/custom_info.dart';

@HiveType(typeId: 4)
class SkoobUser extends HiveObject {
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

  SkoobUser(
      {required this.name,
      required this.email,
      this.photoUrl = '',
      this.phoneNumber = '',
      this.latestFeedBookTitle = '',
      this.latestFeedStatus = BookReadingStatus.initial,
      }
  );

  Map<String, String> toMap() {
    return {
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
    try {
      var name = reader.readString();
      var email = reader.readString();
      var photoUrl = reader.readString();
      var phoneNumber = reader.readString();
      var latestFeedBookTitle = reader.readString();
      int latestFeedStatusIndex = reader.readByte();
      var latestFeedStatus = BookReadingStatus.values[latestFeedStatusIndex];
      return SkoobUser(
          name: name,
          email: email,
          photoUrl: photoUrl,
          phoneNumber: phoneNumber,
          latestFeedBookTitle: latestFeedBookTitle,
          latestFeedStatus: latestFeedStatus
      );
    } catch (e) {
      print('Failed to read SkoobUser: $e');
      rethrow;
    }
  }

  @override
  void write(BinaryWriter writer, SkoobUser obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.photoUrl);
    writer.writeString(obj.phoneNumber);
    writer.writeString(obj.latestFeedBookTitle);
    writer.writeByte(obj.latestFeedStatus.index);
  }
}