import 'dart:async';
import 'package:flutter/material.dart';

mixin PeriodicTaskMixin<T extends StatefulWidget> on State<T> {
  Timer? _timer;
  Duration get interval;

  void onTick();

  bool get runImmediately => true;

  @override
  void initState() {
    super.initState();
    
    if (runImmediately) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onTick();
      });
    }
    
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(interval, (timer) {
      if (mounted) {
        onTick();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}