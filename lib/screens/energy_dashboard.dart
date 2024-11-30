import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_status_provider.dart';
import '../widgets/status_card.dart';

class EnergyDashboard extends StatefulWidget {
  @override
  _EnergyDashboardState createState() => _EnergyDashboardState();
}

class _EnergyDashboardState extends State<EnergyDashboard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Fetch initial data
    Future.microtask(() {
      Provider.of<RoomStatusProvider>(context, listen: false)
          .fetchWindowsFromApi(false);
    });

    // Set up a periodic timer to refresh data every 15 seconds
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      Provider.of<RoomStatusProvider>(context, listen: false)
          .fetchWindowsFromApi(false);
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Energy Monitor'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Consumer<RoomStatusProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            // Show loading indicator while data is being fetched
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.windows.isEmpty) {
            // Handle case when no windows are available
            return Center(
              child: Text("No window data available."),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display energy consumption
                StatusCard(
                  title: "Energy Consumption",
                  value: provider.energyConsumption + " kWh",
                  icon: Icons.energy_savings_leaf,
                  iconColor: Colors.green,
                  switchValue: false, // No switch for energy consumption
                  onSwitchChanged: (value) {},
                ),
                SizedBox(height: 16),

                // Display windows dynamically with switches
                ...provider.windows.map((window) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: StatusCard(
                      title: "${window['name']}\nID: (${window["id"]})",
                      value: window["status"],
                      icon: Icons.window,
                      iconColor:
                          window["status"] == "Closed" ? Colors.blue : Colors.red,
                      switchValue: window["status"] == "on",
                      onSwitchChanged: (value) {
                        // Show progress bar while data is being fetched
                        setState(() {
                          provider.isLoading = true;
                        });

                        // Send the data to change the window status
                        provider.changeDeviceStatus(
                          window["id"].toString(),  // Device ID
                          value ? "on" : "off",  // Status
                          "Window",  // Device type
                        );
                      },
                    ),
                  );
                }).toList(),

                SizedBox(height: 16),

                // Display AC status with switch
                StatusCard(
                  title: "AC",
                  value: provider.acStatus,
                  icon: Icons.ac_unit,
                  iconColor:
                      provider.acStatus == "on" ? Colors.blue : Colors.grey,
                  switchValue: provider.acStatus == "on",
                  onSwitchChanged: (value) async {
                    // Show progress bar while data is being fetched
                    setState(() {
                      provider.isLoading = true;
                    });

                    // Send the data to change the AC status
                    await provider.changeDeviceStatus(
                      provider.ac_id.toString(),  // Replace with actual AC device ID
                      value ? "on" : "off",  // Status
                      "AC",  // Device type
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
