import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:working_system_app/Types/JSONObject/GivingReviewBody.dart';
import 'package:working_system_app/Types/JSONObject/WorkerReview.dart';

class GivingReview extends StatefulWidget {
  final WorkerReview unreviewedGig;
  final String sessionKey;

  const GivingReview({
    super.key,
    required this.unreviewedGig,
    required this.sessionKey,
  });

  @override
  State<GivingReview> createState() => _GivingReviewState();
}

class _GivingReviewState extends State<GivingReview> {
  GivingReviewBody reviewBody = GivingReviewBody(ratingValue: 0, comment: null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Give Review")),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        child: ListTile(
                          title: Text(widget.unreviewedGig.title),
                          subtitle: Text(
                            "Duration: ${DateFormat('MMMM d, yyyy').format(widget.unreviewedGig.startDate)} - ${DateFormat('MMMM d, yyyy').format(widget.unreviewedGig.endDate)}",
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text("Your rating:"),
                      SizedBox(height: 8),
                      RatingBar.builder(
                        allowHalfRating: false,
                        minRating: 1,
                        itemPadding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                        ),
                        itemBuilder: (context, _) =>
                            Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) {
                          setState(() {
                            reviewBody.ratingValue = rating.toInt();
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextField(
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Leave a comment (optional)',
                          labelText: 'Comment',
                        ),
                        onChanged: (text) {
                          setState(() {
                            reviewBody.comment = text.isEmpty ? null : text;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {},
                    child: Text("Review"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
