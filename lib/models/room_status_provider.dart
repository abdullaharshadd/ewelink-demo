import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert'; // Import to use jsonEncode

class RoomStatusProvider extends ChangeNotifier {
  String _energyConsumption = "";
  String _acStatus = "";
  List<Map<String, dynamic>> _windows = [];
  bool _isLoading = false;
  String _ac_id = "";
  String get ac_id => _ac_id;
  String get energyConsumption => _energyConsumption;
  String get acStatus => _acStatus;
  List<Map<String, dynamic>> get windows => _windows;
  bool get isLoading => _isLoading;

  // Setter for isLoading
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Other methods like updateEnergyConsumption, toggleAcStatus, etc.
  void updateEnergyConsumption(String newConsumption) {
    _energyConsumption = newConsumption;
    notifyListeners();
  }

  void toggleAcStatus() {
    _acStatus = (_acStatus == "on") ? "off" : "on";
    notifyListeners();
  }

  void toggleWindowStatus(String windowId) {
    int index = _windows.indexWhere((window) => window["id"] == windowId);
    if (index != -1) {
      _windows[index]["status"] =
          (_windows[index]["status"] == "off") ? "on" : "off";
      notifyListeners();
    }
  }

  void toggleACStatus(String newStatus) {
    _acStatus = newStatus;
    notifyListeners();
  }

  void updateWindows(List<Map<String, dynamic>> newWindows) {
    _windows = newWindows;
    notifyListeners();
  }

  // Fetch data from API
  Future<void> fetchWindowsFromApi(latestRequired) async {
    String apiUrl = "https://ewelink-backend.onrender.com/devices-info"; // Replace with your actual API endpoint

    if (latestRequired) {
      apiUrl = apiUrl + "?latestRequired=" + latestRequired.toString();
    }
    isLoading = true;  // Use the setter to update isLoading state

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
        dynamic thingList = data["data"]["thingList"];
        dynamic totalPower = 0;
        if (thingList != null && thingList.isNotEmpty) {
          List<Map<String, dynamic>> fetchedWindows = [];
          for (int a = 0; a < thingList.length; a++) {
            if (thingList[a]["itemData"]["name"].contains("Window")) {
              fetchedWindows.add({
                "id": thingList[a]["itemData"]["deviceid"],
                "name": thingList[a]["itemData"]["name"],
                "status": thingList[a]["itemData"]["params"]["switch"],
              });
            } else {
              _acStatus = thingList[a]["itemData"]["params"]["switches"][0]["switch"];
              _ac_id = thingList[a]["itemData"]["deviceid"];
            }

            totalPower += (thingList[a]["itemData"]["params"]["power"] != null
                ? thingList[a]["itemData"]["params"]["power"]
                : 0);
          }
          _energyConsumption = totalPower.toString();
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
      isLoading = false; // Reset loading state
    }
  }

  Future<void> changeDeviceStatus(deviceId, status, deviceType) async {
    const String apiUrl = "https://ewelink-backend.onrender.com/change-device-status"; // Replace with your actual API endpoint
    
    try {
      print({
          "deviceId": deviceId,
          "status": status,
          "deviceType": deviceType
        });
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "deviceId": deviceId,
          "status": status,
          "deviceType": deviceType
        }),
      );

      final data = jsonDecode(response.body);


      if (response.statusCode == 200) {
        Fluttertoast.showToast(
        msg: data["message"],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
      if (!data["message"].toString().toLowerCase().contains("not")) {
        if (deviceType == 'AC') {
          toggleAcStatus();
        } else {
            toggleWindowStatus(deviceId.toString());
        }
      }
      } else {
        Fluttertoast.showToast(
        msg: data["message"],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
      Fluttertoast.showToast(
        msg: "Couldn't connect to eWeLink service",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
    } finally {
      isLoading = false; // Reset loading state
    }
  }
}
