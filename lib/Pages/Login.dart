import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Pages/Register.dart';
import 'package:working_system_app/Pages/ResetPassword/ResetEnterEmail.dart';

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
  void initState() {
    super.initState();
  }

  void login() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      Map<String, String> body = {"email": email, "password": password};
      final response = await Utils.client.post(
        "/user/login",
        headers: const .rawMap({"platform": "mobile"}),
        body: .json(body),
      );
      if (!mounted) return;
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed. Please try again.")),
        );
        return;
      }
      var cookie = response.headerMap["set-cookie"];
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
      padding: .only(left: 24, right: 24, top: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: .center,
            children: [
              Text("Login", style: TextStyle(fontSize: 24, fontWeight: .bold)),
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
            keyboardType: .emailAddress,
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
            keyboardType: TextInputType.visiblePassword,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(onPressed: login, child: Text("Login")),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: .center,
            children: [
              Text("Don't have an account?"),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                  if (result == true) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Registration successful. Please log in.",
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  "Register",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: 4),
              Text("|"),
              SizedBox(width: 4),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ResetEnterEmail()),
                ),
                child: Text(
                  "Reset Password",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
