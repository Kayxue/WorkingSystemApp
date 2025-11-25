import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

class Constant {
  static const backendUrl = "https://worknowedu.ddns.net/api";
}

enum ApplicationStatus {
  @JsonValue('pending_worker_confirmation')
  pendingWorkerConfirmation(text: '待同意', color: Colors.orange),
  @JsonValue('pending_employer_review')
  pendingEmployerReview(text: '待審核', color: Colors.blueGrey),
  @JsonValue('worker_confirmed')
  workerConfirmed(text: '已通過', color: Colors.green),
  @JsonValue('employer_rejected')
  employerRejected(text: '審核未通過', color: Colors.red),
  @JsonValue('worker_declined')
  workerDeclined(text: '已拒絕', color: Colors.red),
  @JsonValue('worker_cancelled')
  workerCanceled(text: '已取消', color: Colors.grey),
  @JsonValue('system_cancelled')
  systemCanceled(text: '已取消', color: Colors.grey);

  const ApplicationStatus({required this.text, required this.color});

  final String text;
  final Color color;

  Widget get widget => Text(text, style: TextStyle(color: color, fontSize: 16));
}

enum ApplicationPage {
  pendingWorkerConfirmation(status: "pending_worker_confirmation"),
  pendingEmployerReview(status: "pending_employer_review"),
  workerConfirmed(status: "worker_confirmed"),
  inActive(status: "inactive");

  const ApplicationPage({required this.status});

  final String status;
}
