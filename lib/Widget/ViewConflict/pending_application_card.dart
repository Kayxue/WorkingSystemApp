import 'package:flutter/material.dart';
import 'package:working_system_app/Pages/gig_details_no_button.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/pending_application.dart';

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
                  app.status.widget,
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
              if (app.status == .pendingEmployerReview)
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    SizedBox(),
                    OutlinedButton(
                      onPressed: onWithdraw,
                      child: const Text('取消申請'),
                    ),
                  ],
                ),
              if (app.status == .pendingWorkerConfirmation) ...[
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: .start,
                  children: [
                    Text(
                      "若要回覆，請前往「未回覆」頁面進行操作",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
