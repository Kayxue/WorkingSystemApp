import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/ApplicationGig.dart';
import 'package:working_system_app/Types/CustomAppointment.dart';
import 'package:working_system_app/Pages/AttendanceList.dart';
import 'package:working_system_app/Widget/LoadingIndicator.dart';
import 'package:intl/intl.dart';

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
  ScrollController agendaScrollController = ScrollController();
  DateTime currentSelectedDate = DateTime.now();
  List<CustomAppointment> selectedDayAppointments = [];

  _ScheduleState() {
    updateRecentThreeMonths(
      currentSelectedDate.year,
      currentSelectedDate.month,
    );
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

  DateTime adjustDateForMonth(
    DateTime baseDate,
    int targetYear,
    int targetMonth,
  ) {
    DateTime lastDayOfTargetMonth = DateTime(targetYear, targetMonth + 1, 0);
    int maxDayInTargetMonth = lastDayOfTargetMonth.day;
    int adjustedDay = baseDate.day <= maxDayInTargetMonth
        ? baseDate.day
        : maxDayInTargetMonth;
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
    fetchApplication().then((_) {
      _updateSelectedDayAppointments(currentSelectedDate);
    });
    setState(() {
      calendarController.selectedDate = currentSelectedDate;
    });
  }

  void _updateSelectedDayAppointments(DateTime selectedDate) {
    if (_getCalendarDataSource().appointments == null) return;
    List<CustomAppointment> allAppointments =
        _getCalendarDataSource().appointments!.cast<CustomAppointment>();

    final selectedApps = allAppointments.where((appointment) {
      final DateTime start = appointment.startTime;
      final DateTime end = appointment.endTime;
      final DateTime selectedStartOfDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final DateTime selectedEndOfDay = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
      return (start.isBefore(selectedEndOfDay) ||
              start.isAtSameMomentAs(selectedEndOfDay)) &&
          (end.isAfter(selectedStartOfDay) ||
              end.isAtSameMomentAs(selectedStartOfDay));
    }).toList();

    selectedApps.sort((a, b) {
      int hourComparison = a.startTime.hour.compareTo(b.startTime.hour);
      if (hourComparison != 0) {
        return hourComparison;
      }
      return a.startTime.minute.compareTo(b.startTime.minute);
    });

    setState(() {
      selectedDayAppointments = selectedApps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double calendarHeight = MediaQuery.of(context).size.height * 0.5;
    return SafeArea(
      child: isLoading
          ? LoadingIndicator()
          : Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Schedule",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        child: Text(
                          "Check In",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AttendanceList(sessionKey: widget.sessionKey),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: calendarHeight,
                    child: SfCalendar(
                      view: CalendarView.month,
                      initialSelectedDate: currentSelectedDate,
                      dataSource: _getCalendarDataSource(),
                      controller: calendarController,
                      onSelectionChanged: (CalendarSelectionDetails details) {
                        if (details.date != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              currentSelectedDate = details.date!;
                              _updateSelectedDayAppointments(currentSelectedDate);
                              if (agendaScrollController.hasClients) {
                                agendaScrollController.jumpTo(0);
                              }
                            });
                          });
                        }
                      },
                      onViewChanged: (details) async {
                        DateTime viewDate = details
                            .visibleDates[details.visibleDates.length >> 1];

                        if (viewDate.year != currentSelectedDate.year ||
                            viewDate.month != currentSelectedDate.month) {
                          updateRecentThreeMonths(
                            viewDate.year,
                            viewDate.month,
                          );
                          await fetchApplication();
                          DateTime adjustedDate = adjustDateForMonth(
                            currentSelectedDate,
                            viewDate.year,
                            viewDate.month,
                            
                          );
                          setState(() {
                            currentSelectedDate = adjustedDate;
                            calendarController.selectedDate = adjustedDate;
                            _updateSelectedDayAppointments(adjustedDate);
                            if (agendaScrollController.hasClients) {
                              agendaScrollController.jumpTo(0);
                            }
                          });
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      DateFormat('MMMM d, yyyy')
                          .format(currentSelectedDate),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),      
                  Expanded(
                    child: selectedDayAppointments.isEmpty
                        ? Center(
                            child: Text(
                              "No Gigs for this date.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: agendaScrollController,
                            itemCount: selectedDayAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment =
                                  selectedDayAppointments[index];
                              return _AgendaItem(
                                appointment: appointment,
                                selectedDate: currentSelectedDate,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    agendaScrollController.dispose();
    super.dispose();
  }

  _DataSource _getCalendarDataSource() {
    List<ApplicationGig> allApplications = {
      ...?previousMonth,
      ...?thisMonth,
      ...?nextMonth,
    }.toList();
    final List<CustomAppointment> appointments = allApplications.map((e) {
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
      Color color = switch (int.parse(startHour)) {
        >= 6 && < 12 => Colors.orange,
        >= 12 && < 18 => Colors.green,
        _ => Color.fromARGB(255, 59, 211, 231),
      };
      return CustomAppointment(
        startTime: startDatetime,
        endTime: endDatetime,
        subject: e.title,
        color: color,
        gigId: e.gigId,
      );
    }).toList();
    return _DataSource(appointments);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<CustomAppointment> source) {
    appointments = source;
  }
}

class _AgendaItem extends StatelessWidget {
  final CustomAppointment appointment;
  final DateTime selectedDate;

  const _AgendaItem({
    required this.appointment,
    required this.selectedDate,
  });

  String _calculateDayOffset() {
    final startDay = DateTime(
        appointment.startTime.year,
        appointment.startTime.month,
        appointment.startTime.day);
    final selectedDay = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day);
    final diff = selectedDay.difference(startDay).inDays;
    return 'Day ${diff + 1} / ${appointment.endTime.difference(startDay).inDays + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final String timeFormat = DateFormat('jm').format(appointment.startTime) + ' - ' + DateFormat('jm').format(appointment.endTime);
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tapped on gig: ${appointment.subject}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 12.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('j').format(appointment.startTime), 
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    _calculateDayOffset(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),           
            SizedBox(width: 8),
            Expanded(
              child: Container( 
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  border: Border.all(color: appointment.color, width: 4),
                  color: appointment.color,
                  borderRadius: BorderRadius.circular(8),
                ),       
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.subject,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      timeFormat,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
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