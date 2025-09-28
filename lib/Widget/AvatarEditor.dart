import 'package:flutter/material.dart';

class AvatarUpdater extends StatelessWidget {
  const AvatarUpdater({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //TODO: Display Avatar Icon
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () {
                //TODO: Implement select photo logic
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Upload"),
            ),
            FilledButton(
              onPressed: () {
                //TODO: Implement remove avatar logic
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Remove"),
            ),
          ],
        ),
      ],
    );
  }
}
