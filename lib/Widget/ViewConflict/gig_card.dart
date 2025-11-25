import 'package:flutter/material.dart';
import 'package:working_system_app/Others/constant.dart';
import 'package:working_system_app/Pages/gig_details_no_button.dart';
import 'package:working_system_app/Types/JSONObject/Conflict/confirmed_gig.dart';

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
            builder: (context) => GigDetailsNoButton(
              gigId: gig.gigId,
              title: gig.title,
              sessionKey: sessionKey,
            ),
          ),
        );
      },
      child: Card(
        margin: const .symmetric(vertical: 8.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: .circular(8.0)),
        child: Padding(
          padding: const .all(12.0),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    gig.title,
                    style: const TextStyle(fontSize: 18, fontWeight: .bold),
                  ),
                  const Spacer(),
                  ApplicationStatus.workerConfirmed.widget,
                ],
              ),
              const SizedBox(height: 2),
              Text(
                gig.employerName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: .w500,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '時薪${gig.hourlyRate} ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: .w500,
                      ),
                    ),
                    TextSpan(
                      text:
                          '| ${gig.dateStart} - ${gig.dateEnd} (${gig.timeStart} - ${gig.timeEnd})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: .w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${gig.city} ${gig.district} ${gig.address}',
                style: const TextStyle(fontSize: 14, fontWeight: .w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
