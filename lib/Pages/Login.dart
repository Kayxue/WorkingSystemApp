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
  String email = "";
  String password = "";

  _LoginState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {
              email = value;
            }),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {
              password = value;
            }),
            obscureText: true,
          ),
          SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: Text("Login")),
        ],
      ),
    );
  }
}
