import 'package:working_system_app/Pages/MyApplications.dart';
import 'package:flutter/material.dart';
import 'package:working_system_app/Pages/Reviews.dart';
import 'package:working_system_app/Pages/UpdateUserInfo.dart';
import 'package:working_system_app/Pages/UpdateUserPassword.dart';
import 'package:working_system_app/Types/JSONObject/WorkerProfile.dart';
import 'package:working_system_app/Widget/Personal/IconButton.dart';

class ProfileButtonRow extends StatelessWidget {
  final String sessionKey;
  final Function clearSessionKey;
  final Function(int) updateIndex;
  final Function refetchProfile;
  final WorkerProfile profile;
  final int? pendingJobs;
  final int? unratedEmployers;

  const ProfileButtonRow({
    super.key,
    required this.sessionKey,
    required this.clearSessionKey,
    required this.updateIndex,
    required this.profile,
    required this.refetchProfile,
    required this.pendingJobs,
    required this.unratedEmployers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const Padding(
          padding: .only(top: 4, bottom: 16, left: 16),
          child: Text("Actions List", style: TextStyle(fontSize: 16)),
        ),
        Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            ButtonWithIcon(
              withBadge: pendingJobs != null && pendingJobs! > 0,
              badgeNumber: pendingJobs != null ? pendingJobs! : 0,
              iconColor: Colors.black,
              icon: Icons.business_center,
              text: "Gigs Requests",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        MyApplications(sessionKey: sessionKey),
                  ),
                );
              },
            ),
            ButtonWithIcon(
              withBadge: unratedEmployers != null && unratedEmployers! > 0,
              badgeNumber: unratedEmployers != null ? unratedEmployers! : 0,
              iconColor: Colors.black,
              icon: Icons.star,
              text: "Gig Reviews",
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => Reviews(sessionKey: sessionKey),
                ),
              ),
            ),
            ButtonWithIcon(
              withBadge: false,
              badgeNumber: 0,
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
                  ).showSnackBar(const SnackBar(content: Text("Profile updated")));
                  await refetchProfile();
                }
              },
            ),
            ButtonWithIcon(
              withBadge: false,
              badgeNumber: 0,
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
                  ).showSnackBar(const SnackBar(content: Text("Password updated")));
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
