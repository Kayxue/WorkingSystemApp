import 'dart:typed_data';

import 'package:apple_like_avatar_generator/apple_like_avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:working_system_app/Types/WorkerProfile.dart';
import 'package:working_system_app/src/rust/api/core.dart';

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
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image == null) {
                  return;
                }
                debugPrint('Selected image path: ${image.path}');
                ImageInformation info = await getImageInformation(image.path);
                debugPrint(
                  'Image info - Width: ${info.width}, Height: ${info.height}, Format: ${info.format}, Ratio: ${info.ratio}',
                );
                if (info.ratio == 1) {
                  if (!context.mounted) return;
                  final imageSize=await getImageSize(image.path);
                  //TODO: Set image to modify
                  return;
                }
                CroppedFile? croppedFile = await ImageCropper().cropImage(
                  sourcePath: image.path,
                  aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
                  uiSettings: [
                    AndroidUiSettings(
                      toolbarTitle: 'Crop Image',
                      toolbarColor: Colors.lightBlue,
                      toolbarWidgetColor: Colors.white,
                      initAspectRatio: CropAspectRatioPreset.square,
                      lockAspectRatio: true,
                    ),
                    IOSUiSettings(
                      title: 'Crop Image',
                      aspectRatioLockEnabled: true,
                    ),
                  ],
                );
                if (croppedFile == null) {
                  return;
                }
                debugPrint('Cropped image path: ${croppedFile.path}');
                final imageSize = await getImageSize(croppedFile.path);
                debugPrint("Image size: $imageSize");
                if(imageSize > 2){
                  if (!context.mounted) return;

                }
                //TODO: Set image to modify
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
