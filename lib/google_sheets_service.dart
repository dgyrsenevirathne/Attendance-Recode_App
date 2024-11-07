import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

class GoogleSheetsService {
  // Replace with your actual Google Sheets ID
  static const _spreadsheetId = '10EYFwTkxJ05Q0sGU0QHAf1a6hpuIzL3PpRON-uTJB0g';
  // Replace with your actual sheet name (e.g., 'Sheet1')
  static const _sheetName = 'Sheet1';
  // Path to your JSON key file
  static const _credentials =
      'assets/thinking-pillar-441005-c6-e5ceb66885c2.json';

  // Get Sheets API client using service account credentials
  static Future<SheetsApi> _getSheetsApi() async {
    try {
      final credentials = await rootBundle.loadString(_credentials);
      final accountCredentials =
          ServiceAccountCredentials.fromJson(json.decode(credentials));
      final authClient = await clientViaServiceAccount(
          accountCredentials, [SheetsApi.spreadsheetsScope]);
      return SheetsApi(authClient);
    } catch (e) {
      throw Exception("Failed to authenticate with Google Sheets API: $e");
    }
  }

  // Function to add an attendance record (check-in/check-out)
  static Future<void> addAttendanceRecord(
      String employeeNumber, String employeeName, String type) async {
    try {
      final sheetsApi = await _getSheetsApi();

      // Get the current date and time
      final now = DateTime.now();
      final date = '${now.year}-${now.month}-${now.day}';
      final time = '${now.hour}:${now.minute}';

      // Prepare the row data based on type ('in' or 'out')
      final row = [
        employeeNumber,
        employeeName,
        date,
        type == 'in' ? time : '',
        type == 'out' ? time : ''
      ];

      // Append the row to the Google Sheet (starting from row 2, adjusting for header)
      await sheetsApi.spreadsheets.values.append(
        ValueRange(values: [row]),
        _spreadsheetId,
        '$_sheetName!A2', // Start inserting from row 2 (assuming row 1 is for headers)
        valueInputOption:
            'USER_ENTERED', // Use 'USER_ENTERED' to allow Google Sheets to interpret the data (e.g., date/time formats)
      );
    } catch (e) {
      throw Exception("Failed to add attendance record: $e");
    }
  }
}
