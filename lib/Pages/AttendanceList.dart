import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Pages/TakeAttendance.dart';
import 'package:working_system_app/Types/JSONObject/AttendanceToday.dart';
import 'package:working_system_app/Types/JSONObject/AttendanceGigInfo.dart';
import 'package:working_system_app/Widget/Others/LoadingIndicator.dart';

class AttendanceList extends StatefulWidget {
  final String sessionKey;

  const AttendanceList({super.key, required this.sessionKey});

  @override
  State<AttendanceList> createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  List<AttendanceGigInfo> attendanceList = [];
  bool isLoading = true;
  int totalJobs = 0;

  Future<(int, List<AttendanceGigInfo>)?> fetchAttendanceWorks() async {
    final response = await Utils.client.get(
      "/attendance/today-jobs",
      headers: .rawMap({"platform": "mobile", "cookie": widget.sessionKey}),
    );
    if (!mounted) return null;
    if (response.statusCode != 200) {
      await showStatusDialog(
        title: "Error",
        description: "Failed to fetch attendance works. Please try again.",
      );
    }
    final respond = jsonDecode(response.body) as Map<String, dynamic>;
    final parsed = AttendanceToday.fromJson(respond);
    return (parsed.total, parsed.jobs);
  }

  Future<void> showStatusDialog({
    required String title,
    required String description,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchAttendanceWorks().then((result) {
      if (result != null) {
        setState(() {
          totalJobs = result.$1;
          attendanceList = result.$2;
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Today's Attendance")),
      body: isLoading
          ? LoadingIndicator()
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                });
                final result = await fetchAttendanceWorks();
                if (!mounted) return;
                setState(() {
                  if (result != null) {
                    attendanceList = result.$2;
                    totalJobs = result.$1;
                    isLoading = false;
                  }
                });
              },
              child: ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const .symmetric(horizontal: 16.0, vertical: 4.0),
                    clipBehavior: .hardEdge,
                    child: InkWell(
                      splashColor: Colors.grey.withAlpha(30),
                      child: ListTile(
                        title: Text(attendanceList[index].title),
                        subtitle: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              "${attendanceList[index].city} ${attendanceList[index].district}",
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  attendanceList[index].checkedIn
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: attendanceList[index].checkedIn
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                const Text("CheckIn"),
                                const SizedBox(width: 16),
                                Icon(
                                  attendanceList[index].checkedOut
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: attendanceList[index].checkedOut
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                const Text("CheckOut"),
                              ],
                            ),
                          ],
                        ),
                        // time
                        trailing: Text(
                          "${attendanceList[index].timeStart} - ${attendanceList[index].timeEnd}",
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TakeAttendance(
                            gigId: attendanceList[index].gigId,
                            gigTitle: attendanceList[index].title,
                            attendanceTime: attendanceList[index].checkedIn
                                ? attendanceList[index].timeEnd
                                : attendanceList[index].timeStart,
                            attendanceType: attendanceList[index].checkedIn
                                ? "CheckOut"
                                : "CheckIn",
                            sessionKey: widget.sessionKey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
