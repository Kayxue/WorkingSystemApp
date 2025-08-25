import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:working_system_app/Types/GigDetails.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:working_system_app/Widget/EnvironmentPhotoGallery.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class GigInformation extends StatelessWidget {
  final GigDetails gigdetail;

  const GigInformation({super.key, required this.gigdetail});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Text(
                "Details",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: AnimatedReadMoreText(
                  gigdetail.description,
                  maxLines: 2,
                ),
              ),
            ),
            SizedBox(height: 4),
            Card(
              child: ListTile(
                title: Text(
                  "Date",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  "${DateFormat.yMd().format(gigdetail.dateStart)} ～ ${DateFormat.yMd().format(gigdetail.dateEnd)}",
                ),
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: ListTile(
                        title: Text(
                          "Time",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          "${gigdetail.timeStart} ～ ${gigdetail.timeEnd}",
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: ListTile(
                        title: Text(
                          "Hourly Rate",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text("${gigdetail.hourlyRate} NTD/hr"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: Colors.grey.withAlpha(70),
                onTap: () => MapsLauncher.launchQuery(
                  "${gigdetail.city}${gigdetail.district}${gigdetail.address}",
                ),
                child: ListTile(
                  title: Text(
                    "Address",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "${gigdetail.city}${gigdetail.district}${gigdetail.address}",
                  ),
                ),
              ),
            ),
            SizedBox(height: 4),
            Card(
              child: ListTile(
                title: Text(
                  "Requirements",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Table(
                  border: TableBorder.all(style: BorderStyle.none),
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
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
                        Align(
                          alignment: AlignmentGeometry.centerRight,
                          child: const Text(
                            "Skills",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(),
                        Text(gigdetail.requirements.skills.join(", ")),
                      ],
                    ),
                    const TableRow(
                      children: [SizedBox(height: 4), SizedBox(), SizedBox()],
                    ),
                    TableRow(
                      children: [
                        Align(
                          alignment: AlignmentGeometry.centerRight,
                          child: const Text(
                            "Experience",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(),
                        Text(gigdetail.requirements.experience),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (gigdetail.environmentPhotos != null &&
                gigdetail.environmentPhotos!.isNotEmpty) ...[
              SizedBox(height: 8),
              EnvironmentPhotoGallery(gigDetail: gigdetail),
            ],
            SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text(
                  "Contact",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text("Name"),
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
                        leading: Icon(Icons.phone),
                        title: Text("Phone"),
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
                        leading: Icon(Icons.email),
                        title: Text("Email"),
                        subtitle: Text(
                          gigdetail.contactEmail ?? "Not provided",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Updated: ${DateFormat.yMd().format(gigdetail.updatedAt)} ${DateFormat.Hms().format(gigdetail.updatedAt)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "Published: ${DateFormat.yMd().format(gigdetail.publishedAt)} ${DateFormat.Hms().format(gigdetail.publishedAt)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
