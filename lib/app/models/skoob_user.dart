import 'package:hive/hive.dart';

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

  SkoobUser(
      {required this.uid,
      required this.name,
      required this.email,
      required this.photoUrl,
      required this.phoneNumber}
  );

  Map<String, String> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
    };
  }

  static SkoobUser fromMap(Map<String, dynamic> map) {
    return SkoobUser(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        photoUrl: map['photoUrl'] ?? '',
        phoneNumber: map['phoneNumber'] ?? ''
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
    );
  }

  @override
  void write(BinaryWriter writer, SkoobUser obj) {
    writer.writeString(obj.uid);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.phoneNumber);
    writer.writeString(obj.photoUrl);
  }}