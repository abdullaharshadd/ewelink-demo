import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoomStatusProvider extends ChangeNotifier {
  String _energyConsumption = "";
  String _acStatus = "";

  List<Map<String, dynamic>> _windows = [];
  bool _isLoading = false;

  String get energyConsumption => _energyConsumption;
  String get acStatus => _acStatus;
  List<Map<String, dynamic>> get windows => _windows;
  bool get isLoading => _isLoading;

  void updateEnergyConsumption(String newConsumption) {
    _energyConsumption = newConsumption;
    notifyListeners();
  }

  void toggleAcStatus() {
    _acStatus = (_acStatus == "On") ? "Off" : "On";
    notifyListeners();
  }

  void toggleWindowStatus(int windowId) {
    int index = _windows.indexWhere((window) => window["id"] == windowId);
    if (index != -1) {
      _windows[index]["status"] =
          (_windows[index]["status"] == "Closed") ? "Open" : "Closed";
      notifyListeners();
    }
  }

  void updateWindows(List<Map<String, dynamic>> newWindows) {
    _windows = newWindows;
    notifyListeners();
  }

  /// Fetch data from an API using a POST request
  Future<void> fetchWindowsFromApi() async {
    const String apiUrl = "https://ewelink-backend.onrender.com/devices-info"; // Replace with your actual API endpoint

    _isLoading = true;
    notifyListeners();

    try {
        final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
            "Content-Type": "application/json",
        },
        );

        print("Response body: ${response.body}");

        if (response.statusCode == 200) {
        // Parse the JSON response
        final data = jsonDecode(response.body);

        print(data); // Print the data for debugging purposes

        dynamic thingList = data["data"]["thingList"];
        dynamic totalPower = 0;
        if (thingList != null && thingList.isNotEmpty) {
            List<Map<String, dynamic>> fetchedWindows = [];
            for (int a=0; a<thingList.length; a++) {
                        if (thingList[a]["itemData"]["name"].contains("Window")) { // Or any other logic to identify windows
                            fetchedWindows.add({
                            "id": thingList[a]["itemData"]["deviceid"], // Using deviceid as the ID
                            "name": thingList[a]["itemData"]["name"],    // Device name
                            "status": thingList[a]["itemData"]["params"]["switch"], 
                        });
                    } else {    // assuming it to be an AC
                        _acStatus = thingList[a]["itemData"]["params"]["switches"][0]["switch"];
                    }

                    totalPower += (thingList[a]["itemData"]["params"]["power"] != null ? thingList[a]["itemData"]["params"]["power"] : 0);
            }
            _energyConsumption = totalPower.toString() + "kWh";
            updateWindows(fetchedWindows); 
        } else {
            print("No windows data found.");
        }
        } else {
        print("Failed to fetch data: ${response.statusCode}");
        }
    } catch (e) {
        print("Error fetching data: $e");
    } finally {
        _isLoading = false;
        notifyListeners();
    }
    }
}
