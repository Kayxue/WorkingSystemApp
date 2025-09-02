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
  List<ApplicationGig>? previousMonth;
  List<ApplicationGig>? thisMonth;
  List<ApplicationGig>? nextMonth;
  late ((int, int), (int, int), (int, int)) recentThreeMonth;
  bool isLoading = true;
  CalendarController calendarController = CalendarController();
  DateTime currentSelectedDate = DateTime.now();

  _ScheduleState() {
    updateRecentThreeMonths(currentSelectedDate.year, currentSelectedDate.month);
  }

  void updateRecentThreeMonths(int year, int month) {
    DateTime previousM = DateTime(year, month - 1);
    DateTime nextM = DateTime(year, month + 1);
    recentThreeMonth = (
      (previousM.year, previousM.month),
      (year, month),
      (nextM.year, nextM.month),
    );
  }

  /// 處理日期邊界問題
  DateTime adjustDateForMonth(DateTime baseDate, int targetYear, int targetMonth) {
    DateTime lastDayOfTargetMonth = DateTime(targetYear, targetMonth + 1, 0);
    int maxDayInTargetMonth = lastDayOfTargetMonth.day;
    int adjustedDay = baseDate.day <= maxDayInTargetMonth ? baseDate.day : maxDayInTargetMonth;
    return DateTime(targetYear, targetMonth, adjustedDay);
  }

  Future<void> fetchApplication() async {
    var (previousM, cur, nextM) = recentThreeMonth;
    
    final results = await Future.wait([
      fetchApplicationForAMonth(previousM.$1, previousM.$2),
      fetchApplicationForAMonth(cur.$1, cur.$2),
      fetchApplicationForAMonth(nextM.$1, nextM.$2),
    ]);

    setState(() {
      previousMonth = results[0];
      thisMonth = results[1];
      nextMonth = results[2];
      isLoading = false;
    });
  }

  Future<List<ApplicationGig>> fetchApplicationForAMonth(
    int year,
    int month,
  ) async {
    final response = await Utils.client.get(
      "/application/worker/calendar?year=$year&month=$month",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );
    if (response.statusCode != 200) {
      //TODO: Handle when error
    }
    Map<String, dynamic> responseData =
        (jsonDecode(response.body) as Map<String, dynamic>)["data"];
    return (responseData["gigs"] as List<dynamic>)
        .map((e) => ApplicationGig.fromJson(e))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    fetchApplication();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calendarController.selectedDate = currentSelectedDate;
    });
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
                      initialSelectedDate: currentSelectedDate,
                      dataSource: _getCalendarDataSource(),
                      monthViewSettings: MonthViewSettings(showAgenda: true),
                      controller: calendarController,
                      onSelectionChanged: (CalendarSelectionDetails details) {
                        if (details.date != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              currentSelectedDate = details.date!;
                            });
                          });
                        }
                      },
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
                      onViewChanged: (details) {
                        DateTime viewDate = details
                            .visibleDates[details.visibleDates.length >> 1];

                        if (viewDate.year != currentSelectedDate.year ||
                            viewDate.month != currentSelectedDate.month) {
                          updateRecentThreeMonths(viewDate.year, viewDate.month);
                          fetchApplication();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            DateTime adjustedDate = adjustDateForMonth(
                              currentSelectedDate,
                              viewDate.year,
                              viewDate.month,
                            );
                            setState(() {
                              currentSelectedDate = adjustedDate;
                              calendarController.selectedDate = adjustedDate;
                            });
                          });
                        }
                      },
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
        var [endHour, endMin, ..._] = e.timeEnd.split(":");
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
