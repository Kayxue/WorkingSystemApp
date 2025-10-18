import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/JSONObject/WorkerProfile.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:working_system_app/Widget/AvatarEditor.dart';
import 'package:working_system_app/Widget/JobExperienceEditor.dart';

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

  UpdateUserInfo.clone({
    super.key,
    required this.sessionKey,
    required this.clearSessionKey,
    required this.updateIndex,
    required WorkerProfile origin,
  }) : workerProfile = WorkerProfile.clone(origin);

  @override
  State<UpdateUserInfo> createState() => _UpdateUserInfoState();
}

class _UpdateUserInfoState extends State<UpdateUserInfo>
    with SingleTickerProviderStateMixin {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController schoolNameController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  MultiSelectController<String> certificatesController =
      MultiSelectController<String>();
  SlidableController? slidableController;
  Uint8List? avatarBytes;
  String? nameAvatarToChange;
  bool updateAvatar = false;

  void removeJobExperience(String experience) {
    setState(() {
      widget.workerProfile.jobExperience.remove(experience);
    });
  }

  bool addJobExperience(String experience) {
    if (!widget.workerProfile.jobExperience.contains(experience)) {
      setState(() {
        widget.workerProfile.jobExperience.add(experience);
      });
      return true;
    }
    return false;
  }

  void editJobExperience(String oldExperience, String newExperience) {
    setState(() {
      int index = widget.workerProfile.jobExperience.indexOf(oldExperience);
      if (index != -1) {
        widget.workerProfile.jobExperience[index] = newExperience;
      }
    });
  }

  void changeAvatar(Uint8List? avatar, String? fileName) {
    setState(() {
      avatarBytes = avatar;
      nameAvatarToChange = fileName;
      updateAvatar = true;
    });
  }

  Future<bool> updateProfile() async {
    final response = await Utils.client.put(
      "/user/update/profile",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
      body: HttpBody.json(widget.workerProfile.toJson()),
    );
    if (response.statusCode != 200) {
      return false;
    }
    if (updateAvatar) {
      late final HttpBody body;
      if (avatarBytes == null) {
        body = HttpBody.multipart({
          "deleteProfilePhoto": MultipartItem.text(text: "true"),
        });
      } else {
        body = HttpBody.multipart({
          "profilePhoto": MultipartItem.bytes(
            bytes: avatarBytes!,
            fileName: nameAvatarToChange!,
          ),
        });
      }
      final responseAvatar = await Utils.client.put(
        "/user/update/profilePhoto",
        headers: HttpHeaders.rawMap({
          "platform": "mobile",
          "cookie": widget.sessionKey,
        }),
        body: body,
      );
      if (responseAvatar.statusCode != 200) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.workerProfile.firstName;
    lastNameController.text = widget.workerProfile.lastName;
    phoneNumberController.text = widget.workerProfile.phoneNumber;
    schoolNameController.text = widget.workerProfile.schoolName ?? "";
    majorController.text = widget.workerProfile.major ?? "";
    if (widget.workerProfile.certificates != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        certificatesController.selectWhere(
          (item) => widget.workerProfile.certificates!.contains(item.value),
        );
      });
    }
    slidableController = SlidableController(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Information')),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AvatarUpdater(
                        profile: widget.workerProfile,
                        changeAvatar: changeAvatar,
                        avatarBytes: avatarBytes,
                        updateAvatar: updateAvatar,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'First name',
                        ),
                        controller: firstNameController,
                        onChanged: (value) => setState(() {
                          widget.workerProfile.firstName = value;
                        }),
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                        ),
                        controller: lastNameController,
                        onChanged: (value) => setState(() {
                          widget.workerProfile.lastName = value;
                        }),
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                        ),
                        controller: phoneNumberController,
                        onChanged: (value) => setState(() {
                          widget.workerProfile.phoneNumber = value;
                        }),
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
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
                              initialSelection:
                                  widget.workerProfile.highestEducation,
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
                                    widget.workerProfile.highestEducation =
                                        value;
                                  });
                                }
                              },
                              inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'School name',
                        ),
                        controller: schoolNameController,
                        onChanged: (value) => setState(() {
                          widget.workerProfile.schoolName = value.isEmpty
                              ? null
                              : value;
                        }),
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Major'),
                        controller: majorController,
                        onChanged: (value) => setState(() {
                          widget.workerProfile.major = value.isEmpty
                              ? null
                              : value;
                        }),
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      SizedBox(height: 16),
                      Text('Study status', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownMenu(
                              expandedInsets: EdgeInsets.zero,
                              requestFocusOnTap: false,
                              initialSelection:
                                  widget.workerProfile.studyStatus,
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
                              inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('Certificates', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: MultiDropdown(
                              controller: certificatesController,
                              items: [
                                DropdownItem(label: "普通小型車", value: "普通小型車"),
                                DropdownItem(label: "職業小型車", value: "職業小型車"),
                                DropdownItem(label: "普通大貨車", value: "普通大貨車"),
                                DropdownItem(label: "職業大貨車", value: "職業大貨車"),
                                DropdownItem(label: "普通大客車", value: "普通大客車"),
                                DropdownItem(label: "職業大客車", value: "職業大客車"),
                                DropdownItem(label: "普通聯結車", value: "普通聯結車"),
                                DropdownItem(label: "職業聯結車", value: "職業聯結車"),
                                DropdownItem(label: "小型輕型機車", value: "小型輕型機車"),
                                DropdownItem(label: "普通輕型機車", value: "普通輕型機車"),
                                DropdownItem(label: "普通重型機車", value: "普通重型機車"),
                                DropdownItem(label: "大型重型機車", value: "大型重型機車"),
                              ],
                              onSelectionChange: (selectedItems) =>
                                  setState(() {
                                    widget.workerProfile.certificates =
                                        selectedItems;
                                  }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      JobExperienceEditor(
                        removeJobExperience: removeJobExperience,
                        addJobExperience: addJobExperience,
                        editJobExperience: editJobExperience,
                        experienceList: widget.workerProfile.jobExperience,
                        tickerProvider: this,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      if (await updateProfile()) {
                        if (!context.mounted) return;
                        Navigator.of(context).pop(true);
                      } else {
                        if (!context.mounted) return;
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: Text("Save Changes"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
