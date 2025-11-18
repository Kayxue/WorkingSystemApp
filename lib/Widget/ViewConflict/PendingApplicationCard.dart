import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Pages/GigDetailsNoButton.dart';
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
            builder: (context) => GigDetailsNoButton(
              gigId: app.gigId,
              title: app.title,
              sessionKey: sessionKey,
            ),
          ),
        );
      },
      child: Card(
        margin: const .symmetric(vertical: 8.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: .circular(8.0)),
        child: Padding(
          padding: const .all(12.0),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    app.title,
                    style: const TextStyle(fontSize: 18, fontWeight: .bold),
                  ),
                  const Spacer(),
                  StatusTag.getValue(app.status).widget,
                ],
              ),
              const SizedBox(height: 2),
              Text(
                app.employerName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: .w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '時薪${app.hourlyRate} ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange[500],
                                fontWeight: .w500,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '| ${app.dateStart} - ${app.dateEnd} (${app.timeStart} - ${app.timeEnd})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: .w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${app.city} ${app.district} ${app.address}',
                        style: const TextStyle(fontSize: 14, fontWeight: .w500),
                      ),
                    ],
                  ),
                ],
              ),
              if (_buildActionButtons(context).isNotEmpty)
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    SizedBox(),
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
              style: TextStyle(color: Colors.red, fontWeight: .bold),
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
