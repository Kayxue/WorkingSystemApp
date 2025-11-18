import 'package:flutter/material.dart';

class Constant {
  static const backendUrl = "https://worknowedu.ddns.net/api";
}

Map<String, StatusTag> stringStatusMap = {
  'pending_worker_confirmation': .pendingWorkerConfirmation,
  'pending_employer_review': .pendingEmployerReview,
  'worker_confirmed': .workerConfirmed,
  'employer_rejected': .employerRejected,
  'worker_declined': .workerDeclined,
  'worker_cancelled': .workerCanceled,
  'system_cancelled': .systemCanceled,
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

enum ApplicationStatus {
  pendingWorkerConfirmation(statusStr: "pending_worker_confirmation"),
  pendingEmployerReview(statusStr: "pending_employer_review"),
  workerConfirmed(statusStr: "worker_confirmed"),
  inActive(statusStr: "inactive");

  const ApplicationStatus({required this.statusStr});

  final String statusStr;
}
