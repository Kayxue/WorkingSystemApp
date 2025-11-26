import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:working_system_app/Others/utils.dart';
import 'package:working_system_app/Pages/ResetPassword/reset_verification.dart';
import 'package:working_system_app/mixins/waiting_dialog_mixin.dart';
import 'package:working_system_app/src/rust/api/captcha.dart';
import 'package:working_system_app/src/rust/api/password_reset.dart';

class ResetEnterEmail extends StatefulWidget {
  const ResetEnterEmail({super.key});

  @override
  State<ResetEnterEmail> createState() => _ResetEnterEmailState();
}

class _ResetEnterEmailState extends State<ResetEnterEmail>
    with WaitingDialogMixin {
  Uint8List? captchaImage;
  String? captchaAnswer;
  TextEditingController emailController = TextEditingController();
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
        captchaController.text.toLowerCase() == captchaAnswer!.toLowerCase()) {
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

  Future<bool> sendResetPasswordEmail() async {
    showWaitingDialog();
    final response = await Utils.client.post(
      "/user/pw-reset/request",
      headers: .rawMap({"platform": "mobile"}),
      body: .json({"email": emailController.text}),
    );
    if (!mounted) return false;
    hideWaitingDialog();
    if (response.statusCode == 429) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.body)));
      captchaController.clear();
      fetchCaptcha();
      return false;
    }
    if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email address.")),
      );
      captchaController.clear();
      fetchCaptcha();
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
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: captchaController,
                    decoration: InputDecoration(
                      labelText: "Captcha Code",
                      border: OutlineInputBorder(),
                    ),
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
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if (emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Please enter a valid email address.",
                            ),
                          ),
                        );
                        return;
                      }
                      if (!isValidEmail(emailController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Please enter a valid email address.",
                            ),
                          ),
                        );
                        captchaController.clear();
                        fetchCaptcha();
                        return;
                      }
                      if (!checkCaptcha()) {
                        return;
                      }
                      bool success = await sendResetPasswordEmail();
                      if (success) {
                        if (!context.mounted) return;
                        await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Success"),
                            content: Text(
                              "A password reset email has been sent to your email address. Please check your inbox.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                        if (!context.mounted) return;
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) =>
                                ResetVerification(email: emailController.text),
                          ),
                        );
                        if (!context.mounted) return;
                        Navigator.of(context).pop(result);
                      }
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
