import 'package:working_system_app/Pages/MyApplications.dart';
import 'package:flutter/material.dart';
import 'package:working_system_app/Pages/Reviews.dart';
import 'package:working_system_app/Pages/UpdateUserInfo.dart';
import 'package:working_system_app/Pages/UpdateUserPassword.dart';
import 'package:working_system_app/Types/WorkerProfile.dart';
import 'package:working_system_app/Widget/CircleButton.dart';

class ProfileButtonRow extends StatelessWidget {
  final String sessionKey;
  final Function clearSessionKey;
  final Function(int) updateIndex;
  final Function refetchProfile;
  final WorkerProfile profile;

  ProfileButtonRow({
    super.key,
    required this.sessionKey,
    required this.clearSessionKey,
    required this.updateIndex,
    required this.profile,
    required this.refetchProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleButton(
          iconColor: Colors.black,
          icon: Icons.business_center,
          text: "Job Requests",
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyApplicationsPage(
                  sessionKey: sessionKey,
                  userId: profile.userId,
                ),
              ),
            );
          },
        ),
        CircleButton(
          iconColor: Colors.black,
          icon: Icons.star,
          text: "Reviews",
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) => Reviews(sessionKey: sessionKey),
            ),
          ),
        ),
        CircleButton(
          iconColor: Colors.black,
          icon: Icons.account_box,
          text: "Update Profile",
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => UpdateUserInfo.clone(
                  sessionKey: sessionKey,
                  clearSessionKey: clearSessionKey,
                  updateIndex: updateIndex,
                  origin: profile,
                ),
              ),
            );
            if (result != null && result) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Profile updated")));
              await refetchProfile();
            }
          },
        ),
        CircleButton(
          iconColor: Colors.black,
          icon: Icons.password,
          text: "Update Password",
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) =>
                    UpdateUserPassword(sessionKey: sessionKey),
              ),
            );
            if (result != null && result) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Password updated")));
            }
          },
        ),
      ],
    );
  }
}
