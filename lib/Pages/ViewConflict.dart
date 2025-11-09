import 'package:flutter/material.dart';
import 'package:working_system_app/Widget/ViewConflict/ConfirmedList.dart';
import 'package:working_system_app/Widget/ViewConflict/PendingList.dart';

class ViewConflict extends StatefulWidget {
  final String sessionKey;
  final String applicationId;
  final String gigTitle;
  final String conflictType;

  const ViewConflict({
    super.key,
    required this.sessionKey,
    required this.applicationId,
    required this.gigTitle,
    required this.conflictType,
  });

  @override
  State<ViewConflict> createState() => _ViewConflictState();
}

class _ViewConflictState extends State<ViewConflict> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.gigTitle}衝突'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              (widget.conflictType == 'confirmed'
                  ? '以下的工作和您的申請有衝突'
                  : '以下的工作申請和您目前的申請有衝突'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.conflictType == 'confirmed'
                  ? ConfirmedList(
                      sessionKey: widget.sessionKey,
                      conflictType: widget.conflictType,
                      applicationId: widget.applicationId,
                    )
                  : PendingList(
                      sessionKey: widget.sessionKey,
                      conflictType: widget.conflictType,
                      applicationId: widget.applicationId,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
