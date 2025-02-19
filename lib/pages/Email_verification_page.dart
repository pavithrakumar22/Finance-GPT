import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    
    // Send verification email when page first loads if not sent already
    if (FirebaseAuth.instance.currentUser?.emailVerified == false) {
      sendVerificationEmail();
    }
    
    // Allow resending after 60 seconds
    canResendEmail = true;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<bool> manuallyCheckEmailVerified() async {
    try {
      // Force token refresh
      await FirebaseAuth.instance.currentUser!.getIdToken(true);
      
      // Reload user data
      await FirebaseAuth.instance.currentUser!.reload();
      
      // Get fresh verification status
      return FirebaseAuth.instance.currentUser!.emailVerified;
    } catch (e) {
      print("Error checking verification: $e");
      return false;
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 60));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Verify Email'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              size: 100,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 20),
            Text(
              'Verify Your Email',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'We\'ve sent a verification email to:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '${FirebaseAuth.instance.currentUser?.email}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              'Check your email and click the verification link to continue.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: canResendEmail ? sendVerificationEmail : null,
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: canResendEmail ? Colors.deepPurple : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Resend Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Manual verification button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: () async {
                  bool verified = await manuallyCheckEmailVerified();
                  if (verified) {
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email verified! Redirecting...')),
                    );
                    
                    // Give time for the snackbar to show
                    await Future.delayed(Duration(seconds: 1));
                    
                    // Sign out and in again to refresh state
                    try {
                      // Remember the email
                      String? email = FirebaseAuth.instance.currentUser?.email;
                      
                      // Sign out
                      await FirebaseAuth.instance.signOut();
                      
                      // Sign back in - this will trigger MainPage's StreamBuilder
                      // This is a hacky way to force a rebuild - in production you'd
                      // implement custom token auth on your backend
                      if (email != null) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      }
                    } catch (e) {
                      print("Error during sign out/in: $e");
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email not verified yet. Please check your inbox.')),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'I\'ve verified my email',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}