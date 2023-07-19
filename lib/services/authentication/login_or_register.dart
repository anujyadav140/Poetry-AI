import 'package:flutter/material.dart';
import 'package:poetry_ai/pages/login_page.dart';
import 'package:poetry_ai/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //init show login page
  bool showLoginPage = true;
  //toggle between the states
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onClick: togglePages);
    } else {
      return RegisterPage(onClick: togglePages);
    }
  }
}
