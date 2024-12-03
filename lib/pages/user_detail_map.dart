import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailMap extends StatefulWidget {
  final String userId;

  const UserDetailMap({super.key, required this.userId});

  @override
  State<UserDetailMap> createState() => _UserDetailMapState();
}

class _UserDetailMapState extends State<UserDetailMap> {
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  LatLng? currentPos;
  LatLng? startPos;
  LatLng? endPos;
  final Set<Polyline> _polylines = <Polyline>{};
  final Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    fetchUserLocation();
  }

  Future<void> fetchUserLocation() async {
    try {
      // Fetch user document from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (!snapshot.exists) {
        throw Exception("User data not found.");
      }

      final data = snapshot.data() as Map<String, dynamic>?;

      // Validate and parse location data
      final dailyLocation = data?['dailyLocation'] as Map<String, dynamic>?;

      if (dailyLocation == null) {
        throw Exception("Daily location data is missing.");
      }

      final startPoint = dailyLocation['startPoint'] as Map<String, dynamic>?;
      final endPoint = dailyLocation['endPoint'] as Map<String, dynamic>?;
      final locations = (dailyLocation['locations'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      if (startPoint == null || endPoint == null) {
        throw Exception("Start or end point data is missing.");
      }

      // Update state with fetched data
      setState(() {
        startPos = LatLng(startPoint['lat'], startPoint['lng']);
        endPos = LatLng(endPoint['lat'], endPoint['lng']);
        currentPos = endPos;

        // Add start and end markers
        _markers.addAll([
          Marker(
            markerId: const MarkerId("startLocation"),
            position: startPos!,
            infoWindow: const InfoWindow(title: "Start Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
          Marker(
            markerId: const MarkerId("endLocation"),
            position: endPos!,
            infoWindow: const InfoWindow(title: "End Location"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        ]);

        // Add markers for intermediate locations
        for (int i = 0; i < locations.length; i++) {
          final loc = locations[i];
          if (loc.containsKey('lat') && loc.containsKey('lng')) {
            final lat = loc['lat'];
            final lng = loc['lng'];
            _markers.add(
              Marker(
                markerId: MarkerId("location_$i"),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: "Intermediate Location $i",
                  snippet: "Lat: $lat, Lng: $lng",
                ),
              ),
            );
          }
        }

        // Create a polyline for the route
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: [
              startPos!,
              ...locations.map((loc) => LatLng(loc['lat'], loc['lng'])),
              endPos!,
            ],
            color: Colors.blue,
            width: 4,
          ),
        );
      });

      // Move camera to the current position
      if (currentPos != null) {
        cameraToPos(currentPos!);
      }
    } catch (e) {
      debugPrint("Error fetching user location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user location: $e")),
      );
    }
  }

  Future<void> cameraToPos(LatLng pos) async {
    try {
      final GoogleMapController controller = await mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 13)),
      );
    } catch (e) {
      debugPrint("Error moving camera: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Location'),
        backgroundColor: Colors.deepPurple,
      ),
      body: currentPos == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) =>
                  mapController.complete(controller),
              initialCameraPosition:
                  CameraPosition(target: currentPos!, zoom: 13),
              markers: _markers,
              polylines: _polylines,
            ),
    );
  }
}
