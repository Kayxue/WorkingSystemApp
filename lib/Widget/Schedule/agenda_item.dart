import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_system_app/Pages/gig_details_no_button.dart';
import 'package:working_system_app/Types/custom_appointment.dart';

class AgendaItem extends StatelessWidget {
  final CustomAppointment appointment;
  final DateTime selectedDate;
  final String sessionKey;

  const AgendaItem({
    super.key,
    required this.appointment,
    required this.selectedDate,
    required this.sessionKey,
  });

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
            builder: (context) => GigDetailsNoButton(
              gigId: appointment.gigId,
              title: appointment.subject,
              sessionKey: sessionKey,
            ),
          ),
        );
      },
      child: Padding(
        padding: const .symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: .start,
          children: [
            Container(
              width: 80,
              alignment: .topRight,
              padding: const .only(right: 12.0, top: 4.0),
              child: Column(
                crossAxisAlignment: .end,
                children: [
                  Text(
                    DateFormat('j').format(appointment.startTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _calculateDayOffset(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const .symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  border: Border.all(color: appointment.color, width: 4),
                  color: appointment.color,
                  borderRadius: .circular(8),
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      appointment.subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: .bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      timeFormat,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
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
