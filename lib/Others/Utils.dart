import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Constant.dart';
import 'package:working_system_app/Types/JSONObject/PersonalUnread.dart';

class Utils {
  static Future<Map<String, List<String>>> loadCityDistrictMap() async {
    final String jsonString = await rootBundle.loadString(
      'assets/AreaData.json',
    );
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  static var client = RhttpClient.createSync(
    settings: const ClientSettings(
      throwOnStatusCode: false,
      baseUrl: Constant.backendUrl,
    ),
  );

  static Future<PersonalUnread?> fetchUnread(String sessionKey) async {
    final response = await Utils.client.get(
      "/user/worker/states",
      headers: .rawMap({"platform": "mobile", "cookie": sessionKey}),
    );
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final result = PersonalUnread.fromJson(body);
    return result;
  }
}
