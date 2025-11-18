import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:working_system_app/Types/JSONObject/GigDetails.dart';

class EnvironmentPhotoGallery extends StatelessWidget {
  final GigDetails gigDetail;

  const EnvironmentPhotoGallery({super.key, required this.gigDetail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(left: 4, right: 4),
      child: Column(
        children: [
          const Padding(
            padding: .only(left: 4, right: 4),
            child: Align(
              alignment: .topLeft,
              child: Text(
                "Environment Photo",
                style: TextStyle(fontWeight: .w500, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 256,
            child: SingleChildScrollView(
              scrollDirection: .horizontal,
              child: Row(
                children: gigDetail.environmentPhotos!
                    .map(
                      (e) => Padding(
                        padding: .only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  extendBodyBehindAppBar: true,
                                  appBar: AppBar(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  body: PhotoView(
                                    imageProvider: NetworkImage(e.url),
                                    minScale: PhotoViewComputedScale.contained,
                                    heroAttributes: PhotoViewHeroAttributes(
                                      tag: e.originalName,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: .circular(16),
                            child: Image.network(e.url, height: 256),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
