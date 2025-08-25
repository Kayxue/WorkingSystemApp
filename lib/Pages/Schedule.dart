import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
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
                  if (details.targetElement != CalendarElement.appointment) {
                    return;
                  }
                  if (details.appointments != null) {
                    // This condition ensures the tap was on an appointment
                    if (details.appointments!.isNotEmpty) {
                      final appointment = details.appointments!.first;
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  _DataSource _getCalendarDataSource() {
    final List<Appointment> appointments = <Appointment>[];
    appointments.add(
      Appointment(
        startTime: DateTime.now().add(const Duration(hours: 9)),
        endTime: DateTime.now().add(const Duration(hours: 10)),
        subject: 'Morning Meeting',
        color: Colors.blue,
      ),
    );
    appointments.add(
      Appointment(
        startTime: DateTime.now().add(const Duration(hours: 14)),
        endTime: DateTime.now().add(const Duration(hours: 15)),
        subject: 'Lunch with John',
        color: Colors.green,
      ),
    );
    appointments.add(
      Appointment(
        startTime: DateTime.now().add(const Duration(hours: 16)),
        endTime: DateTime.now().add(const Duration(hours: 17)),
        subject: 'Project Review',
        color: Colors.purple,
      ),
    );
    return _DataSource(appointments);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
