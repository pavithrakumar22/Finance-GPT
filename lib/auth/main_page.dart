import 'package:fgpt/auth/auth_page.dart';
import 'package:fgpt/pages/home_page.dart';
import 'package:fgpt/pages/email_verification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasData) {
            final user = snapshot.data;
            
            // Force reload user data to get latest verification status
            if (user != null) {
              // This doesn't need to be awaited since we're using a StreamBuilder
              user.reload();
              
              if (user.emailVerified) {
                return HomePage();
              } else {
                return EmailVerificationPage();
              }
            }
          }
          
          return AuthPage();
        },
      ),
    );
  }
}