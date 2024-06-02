import 'dart:convert';

import 'package:http/http.dart' as http;

class FirebaseFunctionService {
  static Future<Map<String, dynamic>> sendStatusUpdatePushMessage(
      String userId, String userName, String bookTitle, String status) async {
    final url = Uri.parse(
        'https://asia-northeast2-skoob-d5938.cloudfunctions.net/sendStatusUpdatePushMessage');

    final response = await http.post(
      url,
      body: {
        'userId': userId,
        'userName': userName,
        'bookTitle': bookTitle,
        'status': status,
      },
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);

    print("SENT ${userId} ${userName} ${bookTitle} ${status}");
    print("SENT ${userId} ${userName} ${bookTitle} ${status}");
    print("SENT ${userId} ${userName} ${bookTitle} ${status}");
    print("SENT ${userId} ${userName} ${bookTitle} ${status}");
    print("SENT ${userId} ${userName} ${bookTitle} ${status}");

    return responseBody;
  }
}
