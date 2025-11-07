import 'package:flutter/material.dart';

class Constant {
  static const backendUrl = "https://worknowedu.ddns.net/api";
}

Map<String, StatusTag> stringStatusMap = {
  'pending_worker_confirmation': StatusTag.pendingWorkerConfirmation,
  'pending_employer_review': StatusTag.pendingEmployerReview,
  'worker_confirmed': StatusTag.workerConfirmed,
  'employer_rejected': StatusTag.employerRejected,
  'worker_declined': StatusTag.workerDeclined,
  'worker_cancelled': StatusTag.workerCanceled,
  'system_cancelled': StatusTag.systemCanceled,
};

enum StatusTag {
  pendingWorkerConfirmation(text: '待同意', color: Colors.orange),
  pendingEmployerReview(text: '待審核', color: Colors.blueGrey),
  workerConfirmed(text: '已通過', color: Colors.green),
  employerRejected(text: '審核未通過', color: Colors.red),
  workerDeclined(text: '已拒絕', color: Colors.red),
  workerCanceled(text: '已取消', color: Colors.grey),
  systemCanceled(text: '已取消', color: Colors.grey);

  const StatusTag({required this.text, required this.color});

  final String text;
  final Color color;

  Widget get widget => Text(text, style: TextStyle(color: color, fontSize: 16));

  factory StatusTag.getValue(String status) => stringStatusMap[status]!;
}
