import 'package:fgpt/pages/LoginPage.dart';
import 'package:fgpt/pages/register_page.dart';
import 'package:fgpt/pages/email_verification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // First, check if there's a current user
    final user = FirebaseAuth.instance.currentUser;

    // If user exists and needs to verify email
    if (user != null && !user.emailVerified) {
      return EmailVerificationPage();
    }
    
    // Otherwise, show login or register page as before
    if (showLoginPage) {
      return LoginPage(showRegisterPage: toggleScreens);
    } else {
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}