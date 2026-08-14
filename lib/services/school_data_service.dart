import 'dart:convert';

import '../config/api_config.dart';
import '../models/school_data.dart';
import 'http_client.dart';

class SchoolDataService {
  static Future<SchoolData> fetchAll() async {
    final res = await apiClient.get(
      Uri.parse('${ApiConfig.schoolDataBaseUrl}/all'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load school data (${res.statusCode})');
    }

    final Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
    final data = json['data'] as Map<String, dynamic>;

    return SchoolData.fromJson(data);
  }
}
