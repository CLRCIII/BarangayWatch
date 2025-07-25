import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report.dart';
import '../models/weather.dart';
import '../services/local_storage_service.dart';
import '../services/local_database_service.dart';

class ReportProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Report> _reports = [];
  bool _isLoading = false;

  List<Report> get reports => [..._reports];
  bool get isLoading => _isLoading;

  Future<void> fetchReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _reports = [];
        return;
      }

      // Get reports from local storage
      final allReports = await LocalDatabaseService.getReports();

      // Filter reports by current user
      _reports =
          allReports.where((report) => report.userId == user.uid).toList();

      // Sort by creation date (newest first)
      _reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error fetching reports: $e');
      _reports = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReport({
    required String title,
    required String description,
    required File imageFile,
    required double latitude,
    required double longitude,
    Weather? weather,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Save image to local storage
      final imagePath = await LocalStorageService.saveImage(imageFile);

      // Create report object
      final newReport = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        userEmail: user.email ?? '',
        title: title,
        description: description,
        imagePath: imagePath,
        latitude: latitude,
        longitude: longitude,
        status: 'Pending',
        createdAt: DateTime.now(),
        weather: weather,
      );

      // Save report to local database
      await LocalDatabaseService.saveReport(newReport);

      // Add to in-memory list
      _reports.insert(0, newReport);
      notifyListeners();
    } catch (e) {
      print('Error creating report: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      // Find the report
      final reportIndex = _reports.indexWhere(
        (report) => report.id == reportId,
      );
      if (reportIndex == -1) {
        throw Exception('Report not found');
      }

      final reportToDelete = _reports[reportIndex];

      // Delete the image file
      try {
        await LocalStorageService.deleteImage(reportToDelete.imagePath);
      } catch (e) {
        print('Warning: Could not delete image file: $e');
        // Continue with report deletion even if image deletion fails
      }

      // Delete from local database
      await LocalDatabaseService.deleteReport(reportId);

      // Remove from in-memory list
      _reports.removeAt(reportIndex);
      notifyListeners();
    } catch (e) {
      print('Error deleting report: $e');
      rethrow;
    }
  }

  Future<void> clearAllReports() async {
    try {
      print('Starting to clear all reports...');

      // Delete all image files first
      for (final report in _reports) {
        try {
          await LocalStorageService.deleteImage(report.imagePath);
          print('Deleted image: ${report.imagePath}');
        } catch (e) {
          print('Warning: Could not delete image file ${report.imagePath}: $e');
          // Continue with other deletions even if one fails
        }
      }

      // Clear from local database
      await LocalDatabaseService.clearAllReports();
      print('Cleared reports from local database');

      // Clear in-memory list
      _reports.clear();
      notifyListeners();
      print('Cleared in-memory reports list');
    } catch (e) {
      print('Error clearing reports: $e');
      rethrow;
    }
  }

  /// Get statistics about reports
  Future<Map<String, int>> getReportStats() async {
    try {
      final stats = <String, int>{
        'total': _reports.length,
        'pending':
            _reports.where((r) => r.status.toLowerCase() == 'pending').length,
        'in_progress':
            _reports
                .where((r) => r.status.toLowerCase() == 'in progress')
                .length,
        'resolved':
            _reports.where((r) => r.status.toLowerCase() == 'resolved').length,
        'rejected':
            _reports.where((r) => r.status.toLowerCase() == 'rejected').length,
      };
      return stats;
    } catch (e) {
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'resolved': 0,
        'rejected': 0,
      };
    }
  }
}
