import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(Object context) {
    return const Center(
      child: Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text("Loading", style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
