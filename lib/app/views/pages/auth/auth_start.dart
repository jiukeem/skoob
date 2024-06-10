import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:skoob/app/services/firebase_analytics.dart';
import 'package:skoob/app/utils/app_colors.dart';
import 'package:skoob/app/views/pages/auth/email_entry.dart';

class AuthStart extends StatelessWidget {
  const AuthStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SKOOB',
                style: TextStyle(
                    fontFamily: 'LexendExaExtraBold',
                    fontSize: 48.0,
                    color: AppColors.white
                ),
              ),
              const SizedBox(height: 32.0,),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)
                  ),
                  foregroundColor: AppColors.softBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10)
                ),
                onPressed: () {
                  AnalyticsService.logEvent('auth_start_button_tapped_continue_with_email');
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmailEntry()));
                },
                child: const Text(
                  'continue with email',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: AppColors.primaryGreen,
                  ),
                )
              ),
            ]),
      ),
    );
  }
}