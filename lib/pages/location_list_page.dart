import 'package:flutter/material.dart';

import 'package:google_map_app/pages/location_detail_page.dart';

class LocationList extends StatefulWidget {
  @override
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  TextEditingController _searchController = TextEditingController();
  List<Location> locations = [
    Location(
      name: 'อาคาร 45 ปีคณะวิทยาศาสตร์',
      landmark: 'อยู่ตรงข้ามกับคณะวิศวกรรมศาสตร์',
      details: 'อาคารรวมสำหรับสาขาในคณะวิทยาศาสตร์',
      imagePath: 'assets/images/location1.jpg',
      latitude: 13.905849646995938, // Latitude of the location
      longitude: 100.60349464085135, // Longitude of the location
    ),
    Location(
      name: 'อาคารจักรพันธ์เพ็ญศิริ',
      landmark: 'อาคารขนาดใหญ่อยู่ติดกับศูนย์เรียนรวม 2 3 และ 4',
      details: 'อาคารขนาดใหญ่',
      imagePath: 'assets/images/location2.jpg',
      latitude: 13.849805372964815, // Example latitude
      longitude: 100.56830608503942, // Example longitude
    ),
    // Add more locations as needed
  ];
  List<Location> filteredLocations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    filteredLocations.clear();
                  } else {
                    filteredLocations = locations
                        .where((location) => location.name
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                        .toList();
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Search locations...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredLocations.isNotEmpty
                ? ListView.builder(
              itemCount: filteredLocations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredLocations[index].name),
                  leading: Image.asset(
                    filteredLocations[index].imagePath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationDetails(
                          location: filteredLocations[index],
                        ),
                      ),
                    );
                  },
                );
              },
            )
                : Center(
              child: Text('Type in the search field to find locations'),
            ),
          ),
        ],
      ),
    );
  }
}

class Location {
  final String name;
  final String landmark;
  final String details;
  final String imagePath;
  final double latitude; // Latitude of the location
  final double longitude; // Longitude of the location

  Location({
    required this.name,
    required this.landmark,
    required this.details,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
  });
}
