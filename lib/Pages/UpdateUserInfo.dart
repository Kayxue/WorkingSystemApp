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
      body: Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'First name'),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Last name'),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Phone number'),
                ),
                //TODO: highestEducation need to use dropdown
                TextField(
                  decoration: const InputDecoration(labelText: 'School name'),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Major'),
                ),
                //TODO: studyStatus need to use dropdown
                //TODO: certificates need to use dropdown
                //TODO: jobExperience need to use ? widget
              ],
            ),
          ),
        ),
      ),
    );
  }
}
