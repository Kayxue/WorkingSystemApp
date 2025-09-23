import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Pages/UpdateUserInfo.dart';
import 'package:working_system_app/Types/WorkerProfile.dart';
import 'package:flutter/services.dart';

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
  bool isLoading = true;

  Future<WorkerProfile> loadUserProfile() async {
    final response = await Utils.client.get(
      "/user/profile",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );
    if (response.statusCode != 200) {
      widget.updateIndex(1);
      widget.clearSessionKey();
    }
    final Map<String, dynamic> respond = jsonDecode(response.body);
    return WorkerProfile.fromJson(respond);
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
  }

  Future<void> logout() async {
    final _ = await Utils.client.get(
      "/user/logout",
      headers: const HttpHeaders.rawMap({"platform": "mobile"}),
    );
    widget.clearSessionKey();
    widget.updateIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Loading", style: TextStyle(fontSize: 12)),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personal",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Card(
                    color: Colors.blue,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${profile.lastName}${profile.firstName}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Your rating:",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    RatingBarIndicator(
                                      rating: profile.ratingStats.averageRating,
                                      itemBuilder: (context, index) =>
                                          Icon(Icons.star, color: Colors.amber),
                                      itemCount: 5,
                                      itemSize: 16.0,
                                      direction: Axis.horizontal,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "(${profile.ratingStats.totalRatings})",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (profile.profilePhoto != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage(
                                  profile.profilePhoto!.url,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: profile.email),
                                      );
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Email copied to clipboard",
                                          ),
                                        ),
                                      );
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
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: profile.phoneNumber,
                                        ),
                                      );
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Phone number copied to clipboard",
                                          ),
                                        ),
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
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.school),
                                    title: Text("Education"),
                                    subtitle: Text(
                                      "${profile.schoolName?.isNotEmpty == true ? profile.schoolName : ""}${profile.major?.isNotEmpty == true ? profile.major : ""}${profile.schoolName?.endsWith(profile.highestEducation) == true ? "" : profile.highestEducation}",
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.badge),
                                    title: Text("Status"),
                                    subtitle: Text(profile.studyStatus),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.check_circle),
                                    title: Text("Certificates"),
                                    subtitle: Text(
                                      profile.certificates != null &&
                                              profile.certificates!.isNotEmpty
                                          ? profile.certificates!.join("、")
                                          : "No certificates",
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.description),
                                    title: Text("Experience"),
                                    subtitle: Text(
                                      profile.jobExperience.isEmpty
                                          ? "No experience"
                                          : profile.jobExperience.join("、"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.of(context)
                                  .push<(bool, WorkerProfile?)>(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateUserInfo.clone(
                                            sessionKey: widget.sessionKey,
                                            clearSessionKey:
                                                widget.clearSessionKey,
                                            updateIndex: widget.updateIndex,
                                            origin: profile,
                                          ),
                                    ),
                                  );
                              if (result != null && result.$1 == true) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Profile updated")),
                                );
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  setState(() {
                                    profile = result.$2!;
                                  });
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(double.infinity, 48),
                            ),
                            child: Text(
                              "Update Information",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              logout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: Size(double.infinity, 48),
                            ),
                            child: Text(
                              "Logout",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 8),
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
