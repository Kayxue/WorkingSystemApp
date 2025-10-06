import 'package:flutter/material.dart';

class ProfileInfoList extends StatelessWidget {
  final List<Widget> children;

  const ProfileInfoList({super.key, required this.children});

  @override
  Widget build(Object context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
