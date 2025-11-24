import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/src/rust/api/password_reset.dart';

class ResetEnterEmail extends StatefulWidget {
  const ResetEnterEmail({super.key});

  @override
  State<ResetEnterEmail> createState() => _ResetEnterEmailState();
}

class _ResetEnterEmailState extends State<ResetEnterEmail> {
  String email = '';

  Future<bool> sendResetPasswordEmail() async {
    final response = await Utils.client.post(
      "/user/pw-reset/request",
      headers: .rawMap({"platform": "mobile"}),
      body: .json({"email": email}),
    );
    if (!mounted) return false;
    if (response.statusCode == 429) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.body)));
      return false;
    }
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to contact server, please ask admin for help."),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: .only(top: 8, left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    "Please enter your email address first.",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {
                      email = value;
                    }),
                  ),
                  //TODO: Add captcha verification here
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if(email.isEmpty || !isValidEmail(email)){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter a valid email address.")),
                        );
                        return;
                      }
                      //TODO: Check captcha
                      bool success = await sendResetPasswordEmail();
                      if (success) {}
                    },
                    child: Text("Reset Password"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
