import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool switchValue; // Switch value
  final Function(bool) onSwitchChanged; // Callback for switch change

  const StatusCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.switchValue,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: iconColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            title != "Energy Consumption" ? 
              // Switch widget
            title.contains("Window") ? Text(
              value == 'off' ? 'Closed' : 'Open',
              style: TextStyle(
                fontWeight: FontWeight.bold, // Makes the text bold
                color: Colors.green,         // Makes the text green
              ),
            )
            : Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
              activeColor: Colors.blue,
              inactiveThumbColor: Colors.red,
            ) : Container(height: 0)
            
          ],
        ),
      ),
    );
  }
}
