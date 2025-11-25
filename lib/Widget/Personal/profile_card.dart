import 'dart:typed_data';

import 'package:apple_like_avatar_generator/apple_like_avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:working_system_app/Pages/Personal/employer_ratings.dart';
import 'package:working_system_app/Types/JSONObject/worker_profile.dart';
import 'package:working_system_app/src/rust/api/core.dart';

class ProfileCard extends StatefulWidget {
  final WorkerProfile profile;
  final String sessionKey;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.sessionKey,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late Future<Uint8List>? _avatarFuture;
  Uint8List? _avatarData;

  @override
  void initState() {
    super.initState();
    _initializeAvatar();
  }

  @override
  void didUpdateWidget(ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only regenerate the avatar if the profile's name changed
    if (oldWidget.profile.firstName != widget.profile.firstName ||
        oldWidget.profile.lastName != widget.profile.lastName) {
      _initializeAvatar();
    }
  }

  void _initializeAvatar() {
    if (widget.profile.profilePhoto == null) {
      _avatarFuture = AppleLikeAvatarGenerator.generateWithFirstNameLastName(
        firstName: widget.profile.firstName,
        lastName: widget.profile.lastName,
      );
      // Store the avatar data once it's generated
      _avatarFuture!.then((data) {
        if (mounted) {
          setState(() {
            _avatarData = data;
          });
        }
      });
    } else {
      _avatarFuture = null;
      _avatarData = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      clipBehavior: .hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  // ChattingRoom(sessionKey: sessionKey)
                  EmployerRatings(
                    profile: widget.profile,
                    sessionKey: widget.sessionKey,
                    avatarData: _avatarData,
                  ),
            ),
          );
        },
        child: Container(
          width: .infinity,
          height: 100,
          padding: .symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Padding(
                padding: .only(left: 16),
                child: Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      getNameToDisplay(
                        widget.profile.firstName,
                        widget.profile.lastName,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: .bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: .center,
                      children: [
                        const Text(
                          "Your rating:",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: .w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        RatingBarIndicator(
                          rating: widget.profile.ratingStats.averageRating,
                          itemBuilder: (context, index) =>
                              Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 16.0,
                          direction: .horizontal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${widget.profile.ratingStats.totalRatings})",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: .underline,
                            decorationColor: Colors.white,
                            decorationStyle: .solid,
                            decorationThickness: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const .only(right: 16.0),
                child: ClipOval(
                  child: widget.profile.profilePhoto != null
                      ? Image.network(
                          widget.profile.profilePhoto!.url,
                          width: 70,
                          height: 70,
                        )
                      : FutureBuilder<Uint8List>(
                          future: _avatarFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == .waiting) {
                              return Container(
                                width: 70,
                                height: 70,
                                color: Colors.transparent,
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
