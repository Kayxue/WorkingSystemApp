import 'package:flutter/material.dart';
import 'package:working_system_app/Types/WorkerProfile.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text('Highest education', style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: DropdownMenu(
                        expandedInsets: EdgeInsets.zero,
                        requestFocusOnTap: false,
                        initialSelection: widget.workerProfile.highestEducation,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: "高中", label: "高中"),
                          DropdownMenuEntry(value: "大學", label: "大學"),
                          DropdownMenuEntry(value: "碩士", label: "碩士"),
                          DropdownMenuEntry(value: "博士", label: "博士"),
                          DropdownMenuEntry(value: "其他", label: "其他"),
                        ],
                        onSelected: (String? value) {
                          if (value != null) {
                            setState(() {
                              widget.workerProfile.highestEducation = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
                Text('Study status', style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: DropdownMenu(
                        expandedInsets: EdgeInsets.zero,
                        requestFocusOnTap: false,
                        initialSelection: widget.workerProfile.studyStatus,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: "就讀中", label: "就讀中"),
                          DropdownMenuEntry(value: "已畢業", label: "已畢業"),
                          DropdownMenuEntry(value: "肆業", label: "肆業"),
                        ],
                        onSelected: (String? value) {
                          if (value != null) {
                            setState(() {
                              widget.workerProfile.studyStatus = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
