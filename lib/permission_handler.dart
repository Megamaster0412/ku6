import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerExample extends StatefulWidget {
  @override
  _PermissionHandlerExampleState createState() => _PermissionHandlerExampleState();
}

class _PermissionHandlerExampleState extends State<PermissionHandlerExample> {
  String _permissionStatus = "Requesting permission...";

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();

    setState(() {
      switch (status) {
        case PermissionStatus.granted:
        // Permission granted
          _permissionStatus = "Location permission granted.";
          break;
        case PermissionStatus.denied:
        // Permission denied
          _permissionStatus = "Location permission denied. Please enable it in app settings.";
          break;
        case PermissionStatus.permanentlyDenied:
        // Permission denied permanently, open app settings to change this
          _permissionStatus = "Location permission permanently denied. Please enable it in app settings.";
          openAppSettings();  // This line will open the app settings to allow the user to change permission settings
          break;
        default:
        // Handle restricted (iOS) or limited case if applicable
          _permissionStatus = "Location permission is restricted.";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Handler Example'),
      ),
      body: Center(
        child: Text(_permissionStatus),
      ),
    );
  }
}
