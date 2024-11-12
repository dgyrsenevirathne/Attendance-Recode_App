import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

class GoogleSheetsService {
  static const _spreadsheetId = '10EYFwTkxJ05Q0sGU0QHAf1a6hpuIzL3PpRON-uTJB0g';
  static const _sheetName = 'Sheet1';
  static const _credentials =
      'assets/thinking-pillar-441005-c6-e5ceb66885c2.json';

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

  static Future<void> addAttendanceRecord(String employeeNumber,
      String employeeName, String type, Map<String, double> location) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final now = DateTime.now();
      final date = '${now.year}-${now.month}-${now.day}';
      final time = '${now.hour}:${now.minute}';
      final latitude = location['latitude'];
      final longitude = location['longitude'];

      // Retrieve existing data to search for a matching row
      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        '$_sheetName!A2:F', // Adjust range as needed
      );

      final rows = response.values ?? [];

      // Check if there’s an existing row for this employee on the same date
      int? rowIndex;
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        if (row.length >= 3 && row[0] == employeeNumber && row[2] == date) {
          rowIndex =
              i + 2; // Add 2 to get actual Google Sheets row index (1-based)
          break;
        }
      }

      if (rowIndex != null) {
        // Update the existing row's "out" time and location
        final range = '$_sheetName!E$rowIndex:F$rowIndex';
        await sheetsApi.spreadsheets.values.update(
          ValueRange(values: [
            [time, '$latitude, $longitude']
          ]),
          _spreadsheetId,
          range,
          valueInputOption: 'USER_ENTERED',
        );
      } else {
        // Append a new row with "in" time and location
        final newRow = [
          employeeNumber,
          employeeName,
          date,
          time,
          '',
          '$latitude, $longitude'
        ];
        await sheetsApi.spreadsheets.values.append(
          ValueRange(values: [newRow]),
          _spreadsheetId,
          '$_sheetName!A:F',
          valueInputOption: 'USER_ENTERED',
        );
      }
    } catch (e) {
      throw Exception("Failed to add attendance record: $e");
    }
  }
}
