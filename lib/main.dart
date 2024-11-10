import 'package:flutter/material.dart';
import 'google_sheets_service.dart'; // Import the GoogleSheetsService

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            Colors.grey[100], // Set a light background color
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50), // Full-width button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
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
      appBar: AppBar(
        title: Text('Attendance Management'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _employeeNumberController,
              decoration: InputDecoration(
                labelText: 'Employee Number',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _employeeNameController,
              decoration: InputDecoration(
                labelText: 'Employee Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: checkIn,
              child: Text('Check In', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: checkOut,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: Text('Check Out', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
