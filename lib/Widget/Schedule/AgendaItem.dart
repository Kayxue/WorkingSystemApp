import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_system_app/Pages/ScheduleGigDetails.dart';
import 'package:working_system_app/Types/CustomAppointment.dart';

class AgendaItem extends StatelessWidget {
  final CustomAppointment appointment;
  final DateTime selectedDate;
  final String sessionKey;

  const AgendaItem({super.key, required this.appointment, required this.selectedDate, required this.sessionKey});

  String _calculateDayOffset() {
    final startDay = DateTime(
      appointment.startTime.year,
      appointment.startTime.month,
      appointment.startTime.day,
    );
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final diff = selectedDay.difference(startDay).inDays;
    return 'Day ${diff + 1} / ${appointment.endTime.difference(startDay).inDays + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final String timeFormat =
        '${DateFormat('jm').format(appointment.startTime)} - ${DateFormat('jm').format(appointment.endTime)}';
    return InkWell(
      onTap: () {
        //navigate to schedule gig detail page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScheduleGigDetails(
              gigId: appointment.gigId,
              title: appointment.subject,
              sessionKey: sessionKey,
            ),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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