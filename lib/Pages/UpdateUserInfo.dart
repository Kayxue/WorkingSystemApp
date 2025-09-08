import 'package:flutter/material.dart';

class UpdateUserInfo extends StatefulWidget {
  final String sessionKey;
  final Function clearSessionKey;
  final Function(int) updateIndex;

  const UpdateUserInfo({
    super.key,
    required this.sessionKey,
    required this.clearSessionKey,
    required this.updateIndex,
  });

  @override
  State<UpdateUserInfo> createState() => _UpdateUserInfoState();
}

class _UpdateUserInfoState extends State<UpdateUserInfo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Uername')),
          ],
        ),
      ),
    );
  }
}
