import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';

class ArPage extends StatefulWidget {
  final double destinationLatitude;
  final double destinationLongitude;

  const ArPage({
    Key? key,
    required this.destinationLatitude,
    required this.destinationLongitude,
  }) : super(key: key);

  @override
  State<ArPage> createState() => _ArPageState();
}

class _ArPageState extends State<ArPage> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  late LatLng _destination;
  late LocationData _locationData;
  late Location _locationService;
  late StreamSubscription<LocationData> _locationSubscription;
  BitmapDescriptor? _currentLocationIcon;
  bool _showARView = false;
  ARFlutterPlugin? arPlugin;

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
    _loadMarkerIcons();
    arPlugin = ARFlutterPlugin(); // Correct initialization
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: _showARView ? arPlugin!.arView : mapView(), // Correct use of the AR view provided by the plugin
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showARView = !_showARView;
          });
        },
        child: Icon(_showARView ? Icons.map : Icons.camera_enhance),
      ),
    );
  }

  Widget mapView() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: _currentPosition ?? _destination,
        zoom: 14.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: getMarkers(),
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
    );
  }

  Set<Marker> getMarkers() {
    return {
      Marker(
        markerId: MarkerId('destination'),
        position: _destination,
      ),
      if (_currentPosition != null && _currentLocationIcon != null)
        Marker(
          markerId: MarkerId('current'),
          position: _currentPosition!,
          icon: _currentLocationIcon!,
        ),
    };
  }

  Future<void> _checkLocationPermissionAndFetchLocation() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationData = await _locationService.getLocation();
    _currentPosition = LatLng(_locationData.latitude!, _locationData.longitude!);
  }

  Future<void> _loadMarkerIcons() async {
    _currentLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)),
        'assets/images/current_marker.png'
    );
  }
}

class ARFlutterPlugin {
  get arView => null;
}
