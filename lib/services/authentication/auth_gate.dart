import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poetry_ai/pages/home_page.dart';
import 'package:poetry_ai/services/authentication/login_or_register.dart';
import 'package:rate_my_app/rate_my_app.dart';

class AuthGate extends StatelessWidget {
  final RateMyApp rateMyApp;
  const AuthGate({super.key, required this.rateMyApp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          //user is logged in
          if (snapshot.hasData) {
            return HomePage(
              rateMyApp: rateMyApp,
            );
          }
          //user is not logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
