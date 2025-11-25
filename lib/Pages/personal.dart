import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:working_system_app/Others/utils.dart';
import 'package:working_system_app/Types/JSONObject/personal_unread.dart';
import 'package:working_system_app/Types/JSONObject/worker_profile.dart';
import 'package:flutter/services.dart';
import 'package:working_system_app/Widget/Base/message_button.dart';
import 'package:working_system_app/Widget/Others/loading_indicator.dart';
import 'package:working_system_app/Widget/Personal/profile_button_row.dart';
import 'package:working_system_app/Widget/Personal/profile_card.dart';
import 'package:working_system_app/Widget/Personal/profile_info_list.dart';

class Personal extends StatefulWidget {
  final String sessionKey;
  final Function clearSessionKey;
  final Function(int) updateIndex;

  const Personal({
    super.key,
    required this.sessionKey,
    required this.clearSessionKey,
    required this.updateIndex,
  });

  @override
  State<Personal> createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  late WorkerProfile profile;
  PersonalUnread? unreadStates;
  bool isLoading = true;

  Future<WorkerProfile> loadUserProfile() async {
    final response = await Utils.client.get(
      "/user/profile",
      headers: .rawMap({"platform": "mobile", "cookie": widget.sessionKey}),
    );
    if (response.statusCode != 200) {
      widget.updateIndex(1);
      widget.clearSessionKey();
    }
    final Map<String, dynamic> respond = jsonDecode(response.body);
    return WorkerProfile.fromJson(respond);
  }

  Future<void> refetchProfile() async {
    setState(() {
      isLoading = true;
    });
    final profile = await loadUserProfile();
    setState(() {
      this.profile = profile;
      isLoading = false;
    });
    refetchUnread();
  }

  void refetchUnread() {
    Utils.fetchUnread(widget.sessionKey).then((unreadStates) {
      if (mounted) {
        setState(() {
          this.unreadStates = unreadStates;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserProfile().then((profile) {
      setState(() {
        this.profile = profile;
        isLoading = false;
      });
    });
    refetchUnread();
  }

  Future<void> logout() async {
    final _ = await Utils.client.get(
      "/user/logout",
      headers: const .rawMap({"platform": "mobile"}),
    );
    widget.clearSessionKey();
    widget.updateIndex(1);
  }

  Future<void> copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$label copied to clipboard")));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? LoadingIndicator()
          : Padding(
              padding: .only(top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      const Text(
                        "Personal",
                        style: TextStyle(fontSize: 24, fontWeight: .bold),
                      ),
                      MessageButton(
                        sessionKey: widget.sessionKey,
                        unreadMessages: unreadStates?.unreadMessages,
                        refetchUnread: () {
                          Utils.fetchUnread(widget.sessionKey).then((
                            unreadStates,
                          ) {
                            if (mounted) {
                              setState(() {
                                this.unreadStates = unreadStates;
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ProfileCard(profile: profile, sessionKey: widget.sessionKey),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: .only(bottom: 8, top: 8),
                              child: ProfileButtonRow(
                                unratedEmployers:
                                    unreadStates?.unratedEmployers,
                                pendingJobs: unreadStates?.pendingJobs,
                                sessionKey: widget.sessionKey,
                                clearSessionKey: widget.clearSessionKey,
                                updateIndex: widget.updateIndex,
                                profile: profile,
                                refetchProfile: refetchProfile,
                                refetchUnread: refetchUnread,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          ProfileInfoList(
                            children: [
                              InkWell(
                                onTap: () {
                                  copyToClipboard(profile.email, "Email");
                                },
                                splashColor: Colors.grey.withAlpha(70),
                                child: ListTile(
                                  leading: Icon(Icons.email),
                                  title: Text("Email"),
                                  subtitle: Text(profile.email),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  copyToClipboard(
                                    profile.phoneNumber,
                                    "Phone number",
                                  );
                                },
                                splashColor: Colors.grey.withAlpha(70),
                                child: ListTile(
                                  leading: Icon(Icons.phone),
                                  title: Text("Phone"),
                                  subtitle: Text(profile.phoneNumber),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ProfileInfoList(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.school),
                                title: const Text("Education"),
                                subtitle: Text(
                                  profile.schoolName?.isEmpty == true &&
                                          profile.major?.isEmpty == true
                                      ? profile.highestEducation
                                      : "${profile.schoolName?.isNotEmpty == true ? profile.schoolName : ""} ${profile.major?.isNotEmpty == true ? profile.major : ""}",
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.badge),
                                title: const Text("Status"),
                                subtitle: Text(profile.studyStatus),
                              ),
                              ListTile(
                                leading: const Icon(Icons.check_circle),
                                title: const Text("Certificates"),
                                subtitle: Text(
                                  profile.certificates != null &&
                                          profile.certificates!.isNotEmpty
                                      ? profile.certificates!.join("、")
                                      : "No certificates",
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.description),
                                title: const Text("Experience"),
                                subtitle: Text(
                                  profile.jobExperience.isEmpty
                                      ? "No experience"
                                      : profile.jobExperience.join("、"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              logout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: Size(.infinity, 48),
                            ),
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
