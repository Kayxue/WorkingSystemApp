import 'package:flutter/material.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Pages/ScheduleGigDetails.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/ConfirmedGig.dart';

class GigCard extends StatelessWidget {
  final ConfirmedGig gig;
  final String sessionKey;

  const GigCard({super.key, required this.gig, required this.sessionKey});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Gig Detail Page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScheduleGigDetails(
              gigId: gig.gigId,
              title: gig.title,
              sessionKey: sessionKey,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    gig.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  StatusTag.getValue('worker_confirmed').widget
                ],
              ),
              const SizedBox(height: 2),
              Text(
                gig.employerName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '時薪${gig.hourlyRate} ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text:
                          '| ${gig.dateStart} - ${gig.dateEnd} (${gig.timeStart} - ${gig.timeEnd})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${gig.city} ${gig.district} ${gig.address}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}