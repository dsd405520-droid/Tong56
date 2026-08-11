import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/school_data.dart';

class SchoolDataService {
  static Future<SchoolData> fetchAll() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/all'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load school data (${res.statusCode})');
    }
    final Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
    return SchoolData.fromJson(json);
  }
}
