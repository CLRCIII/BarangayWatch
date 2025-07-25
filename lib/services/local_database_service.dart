import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report.dart';

class LocalDatabaseService {
  static const String _reportsKey = 'reports';

  /// Save a report to local storage
  static Future<void> saveReport(Report report) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing reports
      final List<Report> reports = await getReports();

      // Add new report
      reports.add(report);

      // Convert to JSON string list with proper DateTime handling
      final List<String> jsonReports =
          reports.map((report) {
            final Map<String, dynamic> reportMap = report.toMap();
            // Convert DateTime to ISO string for JSON serialization
            reportMap['createdAt'] = report.createdAt.toIso8601String();
            return jsonEncode(reportMap);
          }).toList();

      // Save to shared preferences
      await prefs.setStringList(_reportsKey, jsonReports);
    } catch (e) {
      throw Exception('Failed to save report locally: $e');
    }
  }

  /// Get all reports from local storage
  static Future<List<Report>> getReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get JSON string list
      final List<String>? jsonReports = prefs.getStringList(_reportsKey);

      if (jsonReports == null || jsonReports.isEmpty) {
        return [];
      }

      // Convert to Report objects with proper DateTime parsing
      return jsonReports.map((jsonReport) {
        final Map<String, dynamic> reportMap = jsonDecode(jsonReport);

        // Parse DateTime from ISO string
        if (reportMap['createdAt'] is String) {
          reportMap['createdAt'] = DateTime.parse(reportMap['createdAt']);
        }

        // Generate ID if not present
        final String id =
            reportMap['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

        return Report.fromLocalMap(id, reportMap);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get reports from local storage: $e');
    }
  }

  /// Delete a report from local storage
  static Future<void> deleteReport(String reportId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing reports
      final List<Report> reports = await getReports();

      // Remove the report with matching ID
      reports.removeWhere((report) => report.id == reportId);

      // Convert to JSON string list with proper DateTime handling
      final List<String> jsonReports =
          reports.map((report) {
            final Map<String, dynamic> reportMap = report.toMap();
            // Convert DateTime to ISO string for JSON serialization
            reportMap['createdAt'] = report.createdAt.toIso8601String();
            return jsonEncode(reportMap);
          }).toList();

      // Save to shared preferences
      await prefs.setStringList(_reportsKey, jsonReports);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  /// Clear all reports from local storage
  static Future<void> clearAllReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool removed = await prefs.remove(_reportsKey);

      if (!removed) {
        print('Warning: No reports key found to remove');
      }
    } catch (e) {
      throw Exception('Failed to clear reports from local storage: $e');
    }
  }

  /// Check if there are any reports in local storage
  static Future<bool> hasReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonReports = prefs.getStringList(_reportsKey);
      return jsonReports != null && jsonReports.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get the number of reports in local storage
  static Future<int> getReportsCount() async {
    try {
      final reports = await getReports();
      return reports.length;
    } catch (e) {
      return 0;
    }
  }
}
