import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Utils.dart';
import 'package:working_system_app/Types/WorkerProfile.dart';

class Personal extends StatefulWidget {
  final String sessionKey;
  final Function clearSessionKey;
  final Function(int) updateIndex;

  const Personal({
    super.key,
    required this.sessionKey,
    required this.clearSessionKey,
    required this.updateIndex,
  });

  @override
  State<Personal> createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  late WorkerProfile profile;
  bool isLoading = true;

  Future<void> loadUserProfile() async {
    final response = await Utils.client.get(
      "/user/profile",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
    );
    if (response.statusCode != 200) {
      widget.updateIndex(1);
      widget.clearSessionKey();
    }
    final Map<String, dynamic> respond = response.bodyToJson();
    setState(() {
      profile = WorkerProfile.fromJson(respond);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Personal",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Card(
              color: Colors.blue,
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
                            "洛陽停車場",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "台北市萬華區環河南路一段1號",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
