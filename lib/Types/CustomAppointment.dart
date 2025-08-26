import 'package:syncfusion_flutter_calendar/calendar.dart';

class CustomAppointment extends Appointment {
  String gigId;

  CustomAppointment({
    required super.startTime,
    required super.endTime,
    required super.subject,
    required super.color,
    required this.gigId,
  });
}
