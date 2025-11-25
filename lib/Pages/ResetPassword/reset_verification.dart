import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:working_system_app/Others/utils.dart';
import 'package:working_system_app/mixins/waiting_dialog_mixin.dart';

class ResetVerification extends StatefulWidget {
  final String email;
  const ResetVerification({super.key, required this.email});

  @override
  State<ResetVerification> createState() => _ResetVerificationState();
}

class _ResetVerificationState extends State<ResetVerification> with WaitingDialogMixin {
  String verificationCode = "";
  String newPassword = "";

  Future<(bool, String?)> sendResetPasswordRequest() async {
    showWaitingDialog();
    final response = await Utils.client.post(
      "/user/pw-reset/verify",
      headers: .rawMap({"platform": "mobile"}),
      body: .json({
        "email": widget.email,
        "verificationCode": verificationCode,
        "newPassword": newPassword,
      }),
    );
    if (!mounted) return (false, null);
    hideWaitingDialog();
    if (response.statusCode == 200) {
      return (true, null);
    }
    try {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      final errors = (bodyJson["error"] as Map<String, dynamic>);
      final errorMessages = (jsonDecode(errors["message"]) as List<dynamic>)
          .groupListsBy((e) => e["path"][0] as String)
          .entries
          .map(
            (e) =>
                "${e.key} field:\n${e.value.map((v) => " -${v["message"]}").join("\n")}",
          )
          .join("\n");
      return (false, errorMessages);
    } on FormatException {
      return (false, response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: .only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: .center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    "If you do not see the email, please check your spam folder or try again later. If you can't find it after a while, maybe your email address is not registered.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      hint: Text("Enter the code sent to your email"),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        verificationCode = value;
                      });
                    },
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                        keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 32),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      hint: Text("Enter your new password"),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        newPassword = value;
                      });
                    },
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final (success, errorMessage) =
                      await sendResetPasswordRequest();
                  if (!mounted) return;
                  if (success) {
                    Navigator.of(context).pop(true);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Error"),
                        content: Text(
                          errorMessage ?? "An unknown error occurred.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text("Reset Password"),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
