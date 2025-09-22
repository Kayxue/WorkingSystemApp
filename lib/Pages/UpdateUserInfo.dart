import 'package:flutter/material.dart';
import 'package:working_system_app/Types/WorkerProfile.dart';

class UpdateUserInfo extends StatefulWidget {
  final String sessionKey;
  final Function clearSessionKey;
  final Function(int) updateIndex;
  final WorkerProfile workerProfile;

  const UpdateUserInfo({
    super.key,
    required this.sessionKey,
    required this.clearSessionKey,
    required this.updateIndex,
    required this.workerProfile,
  });

  @override
  State<UpdateUserInfo> createState() => _UpdateUserInfoState();
}

class _UpdateUserInfoState extends State<UpdateUserInfo> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController schoolNameController = TextEditingController();
  TextEditingController majorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.workerProfile.firstName;
    lastNameController.text = widget.workerProfile.lastName;
    phoneNumberController.text = widget.workerProfile.phoneNumber;
    schoolNameController.text = widget.workerProfile.schoolName ?? "";
    majorController.text = widget.workerProfile.major ?? "";
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
                  controller: firstNameController,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Last name'),
                  controller: lastNameController,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Phone number'),
                  controller: phoneNumberController,
                ),
                SizedBox(height: 16),
                //TODO: highestEducation need to use dropdown
                TextField(
                  decoration: const InputDecoration(labelText: 'School name'),
                  controller: schoolNameController,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Major'),
                  controller: majorController,
                ),
                SizedBox(height: 16),
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
