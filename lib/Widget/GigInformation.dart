import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:working_system_app/Types/GigDetails.dart';

class GigInformation extends StatelessWidget{
  final GigDetails gigdetail;

  const GigInformation({Key? key, required this.gigdetail});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Updated: ${DateFormat.yMd().format(gigdetail!.updatedAt)} ${DateFormat.Hms().format(gigdetail!.updatedAt)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
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
                  gigdetail!.description,
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
                  "${DateFormat.yMd().format(gigdetail!.dateStart)} ～ ${DateFormat.yMd().format(gigdetail!.dateEnd)}",
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
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "${gigdetail!.timeStart} ～ ${gigdetail!.timeEnd}",
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
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "${gigdetail!.hourlyRate} NTD/hr",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}