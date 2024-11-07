import 'package:flutter/material.dart';
import 'google_sheets_service.dart'; // Import the GoogleSheetsService

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AttendanceHomePage(),
    );
  }
}

class AttendanceHomePage extends StatefulWidget {
  @override
  _AttendanceHomePageState createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> {
  final _employeeNumberController = TextEditingController();
  final _employeeNameController = TextEditingController();

  // Function to handle check-in
  void checkIn() async {
    final employeeNumber = _employeeNumberController.text;
    final employeeName = _employeeNameController.text;

    if (employeeNumber.isNotEmpty && employeeName.isNotEmpty) {
      try {
        await GoogleSheetsService.addAttendanceRecord(
            employeeNumber, employeeName, 'in');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Check-in recorded!')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to record check-in')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter employee details')));
    }
  }

  // Function to handle check-out
  void checkOut() async {
    final employeeNumber = _employeeNumberController.text;
    final employeeName = _employeeNameController.text;

    if (employeeNumber.isNotEmpty && employeeName.isNotEmpty) {
      try {
        await GoogleSheetsService.addAttendanceRecord(
            employeeNumber, employeeName, 'out');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Check-out recorded!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to record check-out')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter employee details')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _employeeNumberController,
              decoration: InputDecoration(labelText: 'Employee Number'),
            ),
            TextField(
              controller: _employeeNameController,
              decoration: InputDecoration(labelText: 'Employee Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkIn,
              child: Text('Check In'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: checkOut,
              child: Text('Check Out'),
            ),
          ],
        ),
      ),
    );
  }
}
