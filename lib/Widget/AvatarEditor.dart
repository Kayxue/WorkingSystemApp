import 'dart:typed_data';

import 'package:apple_like_avatar_generator/apple_like_avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:working_system_app/Types/WorkerProfile.dart';

class AvatarUpdater extends StatelessWidget {
  final WorkerProfile profile;
  final ImagePicker picker = ImagePicker();

  AvatarUpdater({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: profile.profilePhoto != null
              ? Image.network(profile.profilePhoto!.url, width: 70, height: 70)
              : FutureBuilder<Uint8List>(
                  future: AppleLikeAvatarGenerator.generateWithName(
                    "${profile.firstName}${profile.lastName}",
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: Colors.transparent, // Transparent background
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        width: 70,
                        height: 70,
                      );
                    } else {
                      return const Text('No data');
                    }
                  },
                ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                //TODO: Implement select photo logic
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  // Handle the selected image file
                  print('Selected image path: ${image.path}');
                  if (!context.mounted) return;
                } else {
                  // User canceled the picker
                  print('No image selected.');
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                fixedSize: Size.fromWidth(105),
              ),
              child: const Text("Upload"),
            ),
            SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                //TODO: Implement remove avatar logic
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                fixedSize: Size.fromWidth(105),
              ),
              child: const Text("Remove"),
            ),
          ],
        ),
      ],
    );
  }
}
