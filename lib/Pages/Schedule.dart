import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/ApplicationGig.dart';
import 'package:working_system_app/Types/CustomAppointment.dart';

class Schedule extends StatefulWidget {
  final String sessionKey;

  const Schedule({super.key, required this.sessionKey});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  (int, int) currentYearMonth = (DateTime.now().year, DateTime.now().month);
  List<ApplicationGig>? previousMonth;
  List<ApplicationGig>? thisMonth;
  List<ApplicationGig>? nextMonth;
  late ((int, int), (int, int), (int, int)) recentThreeMonth;
  bool isLoading = true;

  _ScheduleState() {
    DateTime now = DateTime.now();
    DateTime previousM = DateTime(now.year, now.month - 1, now.day);
    DateTime nextM = DateTime(now.year, now.month + 1, now.day);
    recentThreeMonth = (
      (previousM.year, previousM.month),
      (now.year, now.month),
      (nextM.year, nextM.month),
    );
  }

  Future<void> fetchApplication() async {
    var (previousM, cur, nextM) = recentThreeMonth;
    final thisMonthApplications = await fetchApplicationForAMonth(
      cur.$1,
      cur.$2,
    );
    setState(() {
      thisMonth = thisMonthApplications;
      isLoading = false;
    });
    final previousMonthApplication = await fetchApplicationForAMonth(
      previousM.$1,
      previousM.$2,
    );
    final nextMonthApplication = await fetchApplicationForAMonth(
      nextM.$1,
      nextM.$2,
    );
    setState(() {
      previousMonth = previousMonthApplication;
      nextMonth = nextMonthApplication;
    });
  }

  Future<List<ApplicationGig>> fetchApplicationForAMonth(
    int year,
    int month,
  ) async {
    final thisMonthresponse = await Utils.client.get(
      "/application/worker/calendar?year=$year&month=$month",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );
    if (thisMonthresponse.statusCode != 200) {
      //TODO: Handle when error
    }
    Map<String, dynamic> thisMonthData =
        (jsonDecode(thisMonthresponse.body) as Map<String, dynamic>)["data"];
    return (thisMonthData["gigs"] as List<dynamic>)
        .map((e) => ApplicationGig.fromJson(e))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    fetchApplication();
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
                    "Schedule",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: SfCalendar(
                      view: CalendarView.month,
                      initialSelectedDate: DateTime.now(),
                      dataSource: _getCalendarDataSource(),
                      monthViewSettings: MonthViewSettings(showAgenda: true),
                      onTap: (CalendarTapDetails details) {
                        if (details.targetElement !=
                            CalendarElement.appointment) {
                          return;
                        }
                        if (details.appointments != null) {
                          if (details.appointments!.isNotEmpty) {
                            final appointment = details.appointments!.first;
                            //TODO: Take action when taping on appointment
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Tapped on agenda item: ${appointment.subject}',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      //TODO: Change application data when scroll to next or previous month
                      onViewChanged: (viewChangedDetails) {},
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  _DataSource _getCalendarDataSource() {
    List<ApplicationGig> allApplications = {
      ...?previousMonth,
      ...?thisMonth,
      ...?nextMonth,
    }.toList();
    final List<CustomAppointment> appointments = <CustomAppointment>[
      ...allApplications.map((e) {
        var [startHour, startMin, ..._] = e.timeStart.split(":");
        var [endHour, endMin, ..._] = e.timeStart.split(":");
        DateTime startDatetime = DateTime(
          e.dateStart.year,
          e.dateStart.month,
          e.dateStart.day,
          int.parse(startHour),
          int.parse(startMin),
        );
        DateTime endDatetime = DateTime(
          e.dateEnd.year,
          e.dateEnd.month,
          e.dateEnd.day,
          int.parse(endHour),
          int.parse(endMin),
        );
        return CustomAppointment(
          startTime: startDatetime,
          endTime: endDatetime,
          subject: "${e.title} ${e.gigId}",
          color: Colors.blue,
          gigId: e.gigId,
        );
      }),
    ];
    return _DataSource(appointments);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<CustomAppointment> source) {
    appointments = source;
  }
}
