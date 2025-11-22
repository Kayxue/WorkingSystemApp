import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:working_system_app/Types/JSONObject/GigDetails.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:working_system_app/Widget/GigDetail/EnvironmentPhotoGallery.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:working_system_app/Pages/ViewConflict.dart';

class GigInformation extends StatelessWidget {
  final GigDetails gigdetail;
  final bool applicationGig;
  final String sessionKey;
  final String applicationId;

  const GigInformation({
    super.key,
    required this.gigdetail,
    this.applicationGig = false,
    this.sessionKey = "",
    this.applicationId = "",
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Text(
                "Details",
                style: TextStyle(fontSize: 32, fontWeight: .bold),
              ),
            ),
            const SizedBox(height: 8),
            if ((gigdetail.hasPendingConflict == true ||
                    gigdetail.hasConflict == true) &&
                !(gigdetail.applicationStatus == 'pending_employer_review' ||
                    gigdetail.applicationStatus ==
                        'pending_worker_confirmation' ||
                    gigdetail.applicationStatus == 'worker_confirmed'))
              Container(
                width: .infinity,
                padding: const .all(8.0),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: .circular(8.0),
                ),
                child: const Text(
                  'This job has a conflict with another application.',
                  style: TextStyle(color: Colors.black),
                  textAlign: .center,
                ),
              ),

            if (applicationGig == true &&
                (gigdetail.hasConflict == true ||
                    gigdetail.hasPendingConflict == true) &&
                (gigdetail.applicationStatus == 'pending_employer_review' ||
                    gigdetail.applicationStatus ==
                        'pending_worker_confirmation'))
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ViewConflict(
                        sessionKey: sessionKey,
                        applicationId: applicationId,
                        gigTitle: gigdetail.title,
                        conflictType: gigdetail.hasConflict == true
                            ? 'confirmed'
                            : 'pending',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: .infinity,
                  padding: const .all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: .circular(8.0),
                  ),
                  child: const Text(
                    '此申請與其他申請有衝突，點擊查看。',
                    style: TextStyle(color: Colors.black),
                    textAlign: .center,
                  ),
                ),
              ),

            Card(
              child: ListTile(
                title: const Text(
                  "Description",
                  style: TextStyle(fontWeight: .w500),
                ),
                subtitle: AnimatedReadMoreText(
                  gigdetail.description,
                  maxLines: 2,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Card(
              child: ListTile(
                title: const Text("Date", style: TextStyle(fontWeight: .w500)),
                subtitle: Text(
                  "${DateFormat.yMd().format(gigdetail.dateStart)} ～ ${DateFormat.yMd().format(gigdetail.dateEnd)}",
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: .infinity,
                    child: Card(
                      child: ListTile(
                        title: const Text(
                          "Time",
                          style: TextStyle(fontWeight: .w500),
                        ),
                        subtitle: Text(
                          "${gigdetail.timeStart} ～ ${gigdetail.timeEnd}",
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    width: .infinity,
                    child: Card(
                      child: ListTile(
                        title: const Text(
                          "Hourly Rate",
                          style: TextStyle(fontWeight: .w500),
                        ),
                        subtitle: Text("${gigdetail.hourlyRate} NTD/hr"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Card(
              clipBehavior: .hardEdge,
              child: InkWell(
                splashColor: Colors.grey.withAlpha(70),
                onTap: () => MapsLauncher.launchQuery(
                  "${gigdetail.city}${gigdetail.district}${gigdetail.address}",
                ),
                child: ListTile(
                  title: const Text(
                    "Address",
                    style: TextStyle(fontWeight: .w500),
                  ),
                  subtitle: Text(
                    "${gigdetail.city}${gigdetail.district}${gigdetail.address}",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Card(
              child: ListTile(
                title: const Text(
                  "Requirements",
                  style: TextStyle(fontWeight: .w500),
                ),
                subtitle: Table(
                  border: .all(style: .none),
                  defaultVerticalAlignment: .top,
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: FixedColumnWidth(15),
                    2: FlexColumnWidth(),
                  },
                  children: <TableRow>[
                    const TableRow(
                      children: [SizedBox(height: 4), SizedBox(), SizedBox()],
                    ),
                    TableRow(
                      children: [
                        const Align(
                          alignment: .centerRight,
                          child: Text(
                            "Skills",
                            style: TextStyle(fontWeight: .w500),
                          ),
                        ),
                        const SizedBox(),
                        Text(gigdetail.requirements.skills.join(", ")),
                      ],
                    ),
                    const TableRow(
                      children: [SizedBox(height: 4), SizedBox(), SizedBox()],
                    ),
                    TableRow(
                      children: [
                        const Align(
                          alignment: .centerRight,
                          child: Text(
                            "Experience",
                            style: TextStyle(fontWeight: .w500),
                          ),
                        ),
                        const SizedBox(),
                        Text(gigdetail.requirements.experience),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (gigdetail.environmentPhotos != null &&
                gigdetail.environmentPhotos!.isNotEmpty) ...[
              const SizedBox(height: 8),
              EnvironmentPhotoGallery(gigDetail: gigdetail),
            ],
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text(
                  "Contact",
                  style: TextStyle(fontWeight: .w500),
                ),
                subtitle: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Name"),
                      subtitle: Text(gigdetail.contactPerson),
                    ),
                    InkWell(
                      splashColor: Colors.grey.withAlpha(70),
                      onTap: () async {
                        final Uri launchUri = Uri(
                          scheme: 'tel',
                          path: gigdetail.contactPhone,
                        );
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "You don't have phone app installed",
                              ),
                            ),
                          );
                        }
                      },
                      child: ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text("Phone"),
                        subtitle: Text(
                          gigdetail.contactPhone ?? "Not provided",
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.grey.withAlpha(70),
                      onTap:
                          gigdetail.contactEmail != null &&
                              gigdetail.contactEmail!.isNotEmpty
                          ? () async {
                              final mailtoLink = Mailto(
                                to: [gigdetail.contactEmail!],
                              );
                              if (await canLaunchUrlString(
                                mailtoLink.toString(),
                              )) {
                                await launchUrlString(mailtoLink.toString());
                              } else {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "You don't have email app installed",
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text("Email"),
                        subtitle: Text(
                          gigdetail.contactEmail ?? "Not provided",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "Updated: ${DateFormat.yMd().format(gigdetail.updatedAt)} ${DateFormat.Hms().format(gigdetail.updatedAt)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
