import 'dart:convert';

import 'package:flutter/services.dart';

class Utils {
  static Future<Map<String, List<String>>> loadCityDistrictMap() async {
    final String jsonString = await rootBundle.loadString('assets/city_district_map.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap.map((key, value) => MapEntry(key, List<String>.from(value)));
  }
}