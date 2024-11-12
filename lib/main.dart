import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'google_sheets_service.dart';
import 'splash_screen.dart';

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8), // Semi-transparent input
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
          ),
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context) => AttendanceHomePage(),
      },
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
  final Location _location = Location();

  // Method to get location
  Future<Map<String, double>?> _getLocation() async {
    try {
      final locationData = await _location.getLocation();
      return {
        'latitude': locationData.latitude!,
        'longitude': locationData.longitude!,
      };
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to get location')));
      return null;
    }
  }

  // Function to handle check-in
  void checkIn() async {
    final employeeNumber = _employeeNumberController.text;
    final employeeName = _employeeNameController.text;

    if (employeeNumber.isNotEmpty && employeeName.isNotEmpty) {
      final location = await _getLocation();
      if (location != null) {
        try {
          await GoogleSheetsService.addAttendanceRecord(
              employeeNumber, employeeName, 'in', location);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Check-in recorded!')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to record check-in')));
        }
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
      final location = await _getLocation();
      if (location != null) {
        try {
          await GoogleSheetsService.addAttendanceRecord(
              employeeNumber, employeeName, 'out', location);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Check-out recorded!')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to record check-out')));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter employee details')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/background.jpg'), // Add your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome to Attendance Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black26,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Updated for Check-Out button
                ),
                child: Text('Check Out', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
