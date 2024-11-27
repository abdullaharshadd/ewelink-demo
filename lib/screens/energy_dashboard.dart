import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room_status_provider.dart';
import '../widgets/status_card.dart';

class EnergyDashboard extends StatefulWidget {
  @override
  _EnergyDashboardState createState() => _EnergyDashboardState();
}

class _EnergyDashboardState extends State<EnergyDashboard> {
  @override
  void initState() {
    super.initState();
    // Fetch data before the page loads
    Future.microtask(() {
      Provider.of<RoomStatusProvider>(context, listen: false)
          .fetchWindowsFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Energy Monitor'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              // Refresh data by calling fetchWindowsFromApi
              Provider.of<RoomStatusProvider>(context, listen: false)
                  .fetchWindowsFromApi();
            },
          ),
        ],
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
                  value: provider.energyConsumption,
                  icon: Icons.energy_savings_leaf,
                  iconColor: Colors.green,
                ),
                SizedBox(height: 16),

                // Display windows dynamically
                ...provider.windows.map((window) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: StatusCard(
                      title: "Window ${window["id"]}",
                      value: window["status"],
                      icon: Icons.window,
                      iconColor:
                          window["status"] == "Closed" ? Colors.blue : Colors.red,
                    ),
                  );
                }).toList(),

                SizedBox(height: 16),

                // Display AC status
                StatusCard(
                  title: 'AC',
                  value: provider.acStatus,
                  icon: Icons.ac_unit,
                  iconColor:
                      provider.acStatus == "On" ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
