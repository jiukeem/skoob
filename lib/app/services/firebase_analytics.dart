import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:skoob/app/models/skoob_user.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static SkoobUser? user;

  static void setUser(SkoobUser skoobUser) {
    user = skoobUser;
  }

  static Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    final mergedParameter = {
      'uid': user?.email ?? '',
      ...?parameters,
    };

    await _analytics.logEvent(
      name: eventName,
      parameters: mergedParameter,
    );
    print("Event logged: $eventName");
  }
}