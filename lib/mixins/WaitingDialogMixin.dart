import 'package:flutter/material.dart';

mixin WaitingDialogMixin<T extends StatefulWidget> on State<T> {
  bool _isDialogShowing = false;

  /// Show a waiting dialog with an optional message
  void showWaitingDialog({String message = 'Please wait...'}) {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  /// Hide the waiting dialog if it is showing
  void hideWaitingDialog() {
    if (_isDialogShowing) {
      _isDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
