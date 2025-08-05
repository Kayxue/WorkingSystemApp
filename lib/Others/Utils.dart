import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:rhttp/rhttp.dart';
import 'package:working_system_app/Others/Constant.dart';

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
      baseUrl: Constant.url,
    ),
  );
}
