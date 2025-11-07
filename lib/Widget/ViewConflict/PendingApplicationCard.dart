import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Pages/ScheduleGigDetails.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/PendingApplication.dart';

class PendingApplicationCard extends StatelessWidget {
  final String sessionKey;
  final PendingApplication app;
  final VoidCallback onReject;
  final VoidCallback onWithdraw;

  const PendingApplicationCard({
    super.key,
    required this.app,
    required this.onReject,
    required this.onWithdraw,
    required this.sessionKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Gig Detail Page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScheduleGigDetails(
              gigId: app.gigId,
              title: app.title,
              sessionKey: sessionKey,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    app.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  StatusTag.getValue(app.status).widget
                ],
              ),
              const SizedBox(height: 2),
              Text(
                app.employerName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '時薪${app.hourlyRate} ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '| ${app.dateStart} - ${app.dateEnd} (${app.timeStart} - ${app.timeEnd})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${app.city} ${app.district} ${app.address}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (_buildActionButtons(context).isNotEmpty)
                    Row(children: _buildActionButtons(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    switch (app.status) {
      case 'pending_worker_confirmation':
        return [
          OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text(
              '拒絕',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ];
      case 'pending_employer_review':
        return [
          OutlinedButton(onPressed: onWithdraw, child: const Text('取消申請')),
        ];
      default:
        return [];
    }
  }
}