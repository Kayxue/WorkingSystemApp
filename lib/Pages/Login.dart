import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  final Function(String key) setSessionKey;
  final Function(int index) updateIndex;

  const Login({
    super.key,
    required this.setSessionKey,
    required this.updateIndex,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  _LoginState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        children: [
          Text(
            "Login",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
