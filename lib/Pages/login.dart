import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:working_system_app/Others/utils.dart';
import 'package:working_system_app/Pages/register.dart';
import 'package:working_system_app/Pages/ResetPassword/reset_enter_email.dart';
import 'package:working_system_app/src/rust/api/captcha.dart';

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
  String captchaCode = "";
  Uint8List? captchaImage;
  String? captchaAnswer;
  TextEditingController captchaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCaptcha();
  }

  void fetchCaptcha() {
    generateCaptcha().then((value) {
      final (img, ans) = value;
      setState(() {
        captchaImage = img;
        captchaAnswer = ans;
      });
    });
  }

  bool checkCaptcha() {
    if (captchaAnswer != null &&
        captchaCode.toLowerCase() == captchaAnswer!.toLowerCase()) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Incorrect captcha code. Please try again.")),
      );
      fetchCaptcha();
      captchaController.clear();
      return false;
    }
  }

  void login() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      if (!checkCaptcha()) {
        return;
      }
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
        SnackBar(
          content: Text("Please enter email, password, and captcha code."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: .only(left: 24, right: 24, top: 16),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(fontSize: 24, fontWeight: .bold),
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
                  TextField(
                    controller: captchaController,
                    decoration: InputDecoration(
                      labelText: "Captcha Code",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {
                      captchaCode = value;
                    }),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 16),
                  if (captchaImage != null && captchaAnswer?.isNotEmpty == true)
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          Image.memory(captchaImage!),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: fetchCaptcha,
                            icon: Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: login,
                          child: Text("Login"),
                        ),
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
                        onTap: () async {
                          final result = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (context) => ResetEnterEmail(),
                            ),
                          );
                          if (result == true) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Password reset successful. Please log in with your new password.",
                                ),
                              ),
                            );
                          }
                        },
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
            ),
          ),
        );
      },
    );
  }
}
