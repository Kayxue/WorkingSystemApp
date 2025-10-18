import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';

class UpdateUserPassword extends StatefulWidget {
  final String sessionKey;

  const UpdateUserPassword({super.key, required this.sessionKey});

  @override
  State<UpdateUserPassword> createState() => _UpdateUserPasswordState();
}

class _UpdateUserPasswordState extends State<UpdateUserPassword> {
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';

  bool basicPasswordValidation() {
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords do not match")),
      );
      return false;
    }
    if (newPassword == currentPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New password must be different from current password"),
        ),
      );
      return false;
    }
    return true;
  }

  Future<(bool, String?)> updatePassword() async {
    final response = await Utils.client.put(
      "/user/update/password",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
      body: HttpBody.json({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      }),
    );
    if (response.statusCode == 200) {
      return (true, null);
    }
    try {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      final errors = (bodyJson["errors"] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      final errorMessages = errors
          .map((e) => e["message"] as String)
          .join("\n");
      return (
        false,
        "New password must meet the following criteria:\n$errorMessages",
      );
    } on FormatException {
      return (false, response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Password')),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Current Password',
                          ),
                          onChanged: (value) => setState(() {
                            currentPassword = value;
                          }),
                          obscureText: true,
                          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(labelText: 'New'),
                          onChanged: (value) => setState(() {
                            newPassword = value;
                          }),
                          obscureText: true,
                          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Confirm New Password',
                          ),
                          onChanged: (value) => setState(() {
                            confirmPassword = value;
                          }),
                          obscureText: true,
                          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if (basicPasswordValidation()) {
                        final updateResult = await updatePassword();
                        if (updateResult.$1) {
                          if (!context.mounted) return;
                          Navigator.of(context).pop(true);
                        } else {
                          if (!context.mounted) return;
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Can't update password"),
                                content: Text(updateResult.$2!),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    child: const Text("Update Password"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
