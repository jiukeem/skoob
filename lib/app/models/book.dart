import 'package:skoob/app/models/book/basic_info.dart';
import 'package:skoob/app/models/book/custom_info.dart';

class Book {
  final BasicInfo basicInfo;
  final CustomInfo customInfo;

  Book({required this.basicInfo,required this.customInfo});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> basicInfoJson = basicInfo.toJson();
    final Map<String, dynamic> customInfoJson = customInfo.toJson();
    return {
      'basicInfo': basicInfoJson,
      'customInfoJson': customInfoJson
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
        basicInfo: BasicInfo.fromJson(json['basicInfo'] as Map<String, dynamic>? ?? {}),
        customInfo: CustomInfo.fromJson(json['customInfoJson'] as Map<String, dynamic>? ?? {})
    );
  }
}