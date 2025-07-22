import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:working_system_app/Constant/Constant.dart';

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

  void login() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      Map<String, String> body = {"email": email, "password": password};
      final response = await http.post(
        Uri.parse(
          "http://${Constant.ip}/user/login",
        ),
        headers: {"platform": "mobile"},
        body: body,
      );
      if (!mounted) return;
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed. Please try again.")),
        );
        return;
      }
      var cookie = response.headers["set-cookie"];
      if (cookie != null) {
        widget.updateIndex(0);
        widget.setSessionKey(cookie);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed. No session cookie received.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password.")),
      );
    }
  }

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
          ElevatedButton(onPressed: () {login();}, child: Text("Login")),
        ],
      ),
    );
  }
}
