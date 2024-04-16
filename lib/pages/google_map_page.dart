import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapPage extends StatefulWidget {
  final double destinationLatitude;
  final double destinationLongitude;

  const GoogleMapPage({
    Key? key,
    required this.destinationLatitude,
    required this.destinationLongitude,
  }) : super(key: key);

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  late LatLng _destination;
  late LocationData _locationData;
  late Location _locationService;
  late StreamSubscription<LocationData> _locationSubscription;

  BitmapDescriptor? _currentLocationIcon; // Icon for current location marker

  @override
  void initState() {
    super.initState();
    _destination = LatLng(widget.destinationLatitude, widget.destinationLongitude);
    _locationService = Location();
    _locationSubscription = _locationService.onLocationChanged.listen((LocationData result) {
      setState(() {
        _currentPosition = LatLng(result.latitude!, result.longitude!);
      });
    });
    _checkLocationPermissionAndFetchLocation();
    _loadMarkerIcons(); // Load marker icons
  }

  @override
  void dispose() {
    super.dispose();
    _locationSubscription.cancel();
  }

  Future<void> _checkLocationPermissionAndFetchLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return; // Return if location service is not enabled
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return; // Return if location permission is not granted
      }
    }

    _getCurrentLocation(); // Fetch current location if permissions are granted
  }

  Future<void> _getCurrentLocation() async {
    _locationData = await _locationService.getLocation();
    setState(() {
      _currentPosition = LatLng(_locationData.latitude!, _locationData.longitude!);
    });
  }

  // Load marker icons
  Future<void> _loadMarkerIcons() async {
    final iconData = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/current_marker.png', // Path to custom marker icon
    );
    setState(() {
      _currentLocationIcon = iconData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _currentPosition ?? _destination,
          zoom: 14.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Marker(
            markerId: MarkerId('destination'),
            position: _destination,
          ),
          if (_currentPosition != null && _currentLocationIcon != null) // Add condition for icon
            Marker(
              markerId: MarkerId('current'),
              position: _currentPosition!,
              icon: _currentLocationIcon!, // Use custom icon
            ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: [
              _currentPosition ?? _destination,
              _destination,
            ],
            color: Colors.green,
            width: 3,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentPosition,
        child: Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _moveToCurrentPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(_currentPosition ?? _destination));
  }
}
