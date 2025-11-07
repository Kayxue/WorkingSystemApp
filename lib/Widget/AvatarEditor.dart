import 'dart:typed_data';

import 'package:apple_like_avatar_generator/apple_like_avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:working_system_app/Types/JSONObject/WorkerProfile.dart';
import 'package:working_system_app/src/rust/api/core.dart';

class AvatarUpdater extends StatelessWidget {
  final WorkerProfile profile;
  final Uint8List? avatarBytes;
  final bool updateAvatar;
  final ImagePicker picker = ImagePicker();
  final Function(Uint8List?, String?) changeAvatar;

  AvatarUpdater({
    super.key,
    required this.profile,
    required this.changeAvatar,
    required this.updateAvatar,
    this.avatarBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: !updateAvatar
              ? (profile.profilePhoto == null
                    ? FutureBuilder<Uint8List>(
                        future: AppleLikeAvatarGenerator.generateWithName(
                          "${profile.firstName}${profile.lastName}",
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              width: 70,
                              height: 70,
                              color:
                                  Colors.transparent, // Transparent background
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
                      )
                    : Image.network(
                        profile.profilePhoto!.url,
                        width: 70,
                        height: 70,
                      ))
              : (avatarBytes == null
                    ? FutureBuilder<Uint8List>(
                        future: AppleLikeAvatarGenerator.generateWithName(
                          "${profile.firstName}${profile.lastName}",
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              width: 70,
                              height: 70,
                              color:
                                  Colors.transparent, // Transparent background
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
                      )
                    : Image.memory(avatarBytes!, width: 70, height: 70)),
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
                CroppedFile? croppedFile = await ImageCropper().cropImage(
                  sourcePath: image.path,
                  aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
                  compressFormat: ImageCompressFormat.png,
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
                final (croppedImageName, croppedImageSize) =
                    await getImageNameAndSize(croppedFile.path);
                if (croppedImageSize > 2) {
                  if (!context.mounted) return;
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Image Too Large'),
                      content: Text('Please select an image smaller than 2MB.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                final croppedImageBytes = await readImage(croppedFile.path);
                changeAvatar(croppedImageBytes, croppedImageName);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                fixedSize: Size.fromWidth(105),
              ),
              child: const Text("Choose"),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                if ((avatarBytes == null && updateAvatar) ||
                    (profile.profilePhoto == null && !updateAvatar)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text("No avatar to remove")),
                  );
                  return;
                }
                changeAvatar(null, null);
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
