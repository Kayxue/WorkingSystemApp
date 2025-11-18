import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Pages/ApplicationGigDetails.dart';
import 'package:working_system_app/Pages/ViewConflict.dart';
import 'package:working_system_app/Types/JSONObject/Application.dart';

class ApplicationCard extends StatefulWidget {
  final String sessionKey;
  final Application application;
  final Function(int) moveToPage;
  final Function(String, String) handleActions;
  final Function(String) handleWithdraw;
  final Function() refreshPage;

  const ApplicationCard({
    super.key,
    required this.sessionKey,
    required this.application,
    required this.moveToPage,
    required this.handleActions,
    required this.handleWithdraw,
    required this.refreshPage,
  });

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<ApplicationCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const .symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: .circular(8.0)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => ApplicationGigDetails(
                gigId: widget.application.gigId,
                title: widget.application.gigTitle,
                sessionKey: widget.sessionKey,
                status: widget.application.status,
                applicationId: widget.application.applicationId,
                acceptEnabled: widget.application.hasConflict == true
                    ? false
                    : true,
              ),
            ),
          );

          debugPrint('ApplicationGigDetails returned: $result');

          if (result != null && result == true) {
            await widget.moveToPage(2);
          } else if (result != null && result == false) {
            await widget.moveToPage(3);
          }
        },
        child: Padding(
          padding: const .all(12.0),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    widget.application.gigTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: .bold),
                  ),
                  const Spacer(),
                  StatusTag.getValue(widget.application.status).widget,
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.application.employerName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: .w500,
                ),
                overflow: .ellipsis,
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '時薪${widget.application.hourlyRate} ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[500],
                        fontWeight: .w500,
                      ),
                    ),
                    TextSpan(
                      text:
                          '| ${widget.application.workDate} (${widget.application.workTime})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: .w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.application.hasPendingConflict == true ||
                  widget.application.hasConflict == true)
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewConflict(
                          sessionKey: widget.sessionKey,
                          applicationId: widget.application.applicationId,
                          gigTitle: widget.application.gigTitle,
                          conflictType: widget.application.hasConflict! == true
                              ? 'confirmed'
                              : 'pending',
                        ),
                      ),
                    );

                    if (result == true) {
                      widget.refreshPage();
                    }
                  },
                  child: Container(
                    width: .infinity,
                    margin: const .symmetric(vertical: 8.0),
                    padding: const .all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: .circular(8.0),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '此申請與其他申請的工作時間有衝突。',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: .bold,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.red,
                          size: 16.0,
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    '申請於: ${widget.application.appliedAt.split('T')[0]}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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
    switch (widget.application.status) {
      case 'pending_worker_confirmation':
        return [
          OutlinedButton(
            onPressed: () async => widget.handleActions(
              widget.application.applicationId,
              'reject',
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text(
              '拒絕',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async => widget.handleActions(
              widget.application.applicationId,
              'accept',
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
            ),
            child: const Text(
              '接受',
              style: TextStyle(color: Colors.green, fontWeight: .bold),
            ),
          ),
        ];
      case 'pending_employer_review':
        return [
          OutlinedButton(
            onPressed: () async =>
                widget.handleWithdraw(widget.application.applicationId),
            child: const Text('取消申請'),
          ),
        ];
      default:
        return [];
    }
  }
}
