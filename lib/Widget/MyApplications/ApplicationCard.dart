import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Pages/ApplicationGigDetails.dart';
import 'package:working_system_app/Pages/ViewConflict.dart';
import 'package:working_system_app/Types/JSONObject/Application.dart';

class ApplicationCard extends StatefulWidget {
  final String sessionKey;
  final Application application;
  final Function(int) moveToPage;

  const ApplicationCard({
    super.key,
    required this.sessionKey,
    required this.application,
    required this.moveToPage,
  });

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<ApplicationCard> {
  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('確認'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> handleApplicationAction(
    String applicationId,
    String action,
  ) async {
    final title = action == 'accept' ? '確認接受' : '確認婉拒';
    final content = action == 'accept' ? '您確定要接受此工作邀請嗎？' : '您確定要婉拒此工作邀請嗎？';

    final confirmed = await _showConfirmationDialog(title, content);
    if (!confirmed || !mounted) return;

    try {
      final response = await Utils.client.put(
        '/application/$applicationId/confirm',
        headers: HttpHeaders.rawMap({'cookie': widget.sessionKey}),
        body: HttpBody.json({'action': action}),
      );

      if (response.statusCode == 200) {
        if (action == 'accept') {
          await widget.moveToPage(2);
        } else {
          await widget.moveToPage(3);
        }
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> withdrawApplication(String applicationId) async {
    final confirmed = await _showConfirmationDialog('確認取消申請', '您確定要取消這個工作申請嗎？');
    if (!confirmed || !mounted) return;

    try {
      final response = await Utils.client.post(
        '/application/cancel/$applicationId',
        headers: HttpHeaders.rawMap({'cookie': widget.sessionKey}),
      );

      if (response.statusCode == 200) {
        await widget.moveToPage(3);
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.application.gigTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text:
                          '| ${widget.application.workDate} (${widget.application.workTime})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
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
                      //TODO: Refresh Page
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '此申請與其他申請的工作時間有衝突。',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            onPressed: () async => handleApplicationAction(
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
            onPressed: () async => handleApplicationAction(
              widget.application.applicationId,
              'accept',
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green),
            ),
            child: const Text(
              '接受',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      case 'pending_employer_review':
        return [
          OutlinedButton(
            onPressed: () async =>
                withdrawApplication(widget.application.applicationId),
            child: const Text('取消申請'),
          ),
        ];
      default:
        return [];
    }
  }
}
