import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/room_status_provider.dart';
import 'screens/energy_dashboard.dart';

void main() async {
  // Ensure that async operations are completed before starting the app
  //await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoomStatusProvider()),
      ],
      child: EnergyMonitorApp(),
    ),
  );
}

class EnergyMonitorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EnergyDashboard(),
    );
  }
}
