import 'dart:typed_data';

import 'package:apple_like_avatar_generator/apple_like_avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:working_system_app/Pages/Personal/EmployerRatings.dart';
import 'package:working_system_app/Types/JSONObject/WorkerProfile.dart';

class ProfileCard extends StatelessWidget {
  final WorkerProfile profile;
  final String sessionKey;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.sessionKey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  // ChattingRoom(sessionKey: sessionKey)
                  EmployerRatings(profile: profile, sessionKey: sessionKey),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 100,
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${profile.firstName} ${profile.lastName}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Your rating:",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        RatingBarIndicator(
                          rating: profile.ratingStats.averageRating,
                          itemBuilder: (context, index) =>
                              Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 16.0,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${profile.ratingStats.totalRatings})",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationThickness: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ClipOval(
                  child: profile.profilePhoto != null
                      ? Image.network(
                          profile.profilePhoto!.url,
                          width: 70,
                          height: 70,
                        )
                      : FutureBuilder<Uint8List>(
                          future: AppleLikeAvatarGenerator.generateWithName(
                            "${profile.firstName}${profile.lastName}",
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                width: 70,
                                height: 70,
                                color: Colors
                                    .transparent, // Transparent background
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
