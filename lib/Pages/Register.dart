import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:working_system_app/Types/WorkerRegisterForm.dart';
import 'package:working_system_app/Widget/JobExperienceEditor.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  WorkerRegisterForm registerForm = WorkerRegisterForm();
  SlidableController? slidableController;

  void removeJobExperience(String experience) {
    setState(() {
      registerForm.jobExperience.remove(experience);
    });
  }

  bool addJobExperience(String experience) {
    if (!registerForm.jobExperience.contains(experience)) {
      setState(() {
        registerForm.jobExperience.add(experience);
      });
      return true;
    }
    return false;
  }

  void editJobExperience(String oldExperience, String newExperience) {
    setState(() {
      int index = registerForm.jobExperience.indexOf(oldExperience);
      if (index != -1) {
        registerForm.jobExperience[index] = newExperience;
      }
    });
  }

  @override
  void initState() {
    super.initState();
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
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'First name',
                        ),
                        onChanged: (value) => setState(() {
                          registerForm.firstName = value;
                        }),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                        ),
                        onChanged: (value) => setState(() {
                          registerForm.lastName = value;
                        }),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                        ),
                        onChanged: (value) => setState(() {
                          registerForm.phoneNumber = value;
                        }),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        onChanged: (value) => setState(() {
                          registerForm.email = value;
                        }),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        onChanged: (value) => setState(() {
                          registerForm.password = value;
                        }),
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                        ),
                        onChanged: (value) => setState(() {
                          registerForm.confirmPassword = value;
                        }),
                        obscureText: true,
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
                                    registerForm.highestEducation = value;
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
                        onChanged: (value) => setState(() {
                          registerForm.schoolName = value.isEmpty
                              ? null
                              : value;
                        }),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Major'),
                        onChanged: (value) => setState(() {
                          registerForm.major = value.isEmpty ? null : value;
                        }),
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
                              initialSelection: "就讀中",
                              dropdownMenuEntries: const [
                                DropdownMenuEntry(value: "就讀中", label: "就讀中"),
                                DropdownMenuEntry(value: "已畢業", label: "已畢業"),
                                DropdownMenuEntry(value: "肆業", label: "肆業"),
                              ],
                              onSelected: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    registerForm.studyStatus = value;
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
                                    registerForm.certificates = selectedItems;
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
                        jobExperience: registerForm.jobExperience,
                        controller: slidableController,
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
                      //TODO: Register logic
                    },
                    child: Text("Register"),
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
