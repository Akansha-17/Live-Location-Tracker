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

  @override
  void initState() {
    super.initState();
    fetchUserLocation();
  }

  Future<void> fetchUserLocation() async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);

    try {
      print("Fetching user data for: ${widget.userId}"); // Debugging output
      DocumentSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        double startLat = data['startPoint']['lat'];
        double startLng = data['startPoint']['lng'];
        double endLat = data['endPoint']['lat'];
        double endLng = data['endPoint']['lng'];

        setState(() {
          startPos = LatLng(startLat, startLng);
          endPos = LatLng(endLat, endLng);
          currentPos = LatLng(endLat, endLng);

          // Add the polyline between the start and end positions
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              visible: true,
              points: [startPos!, endPos!],
              color: Colors.blue,
              width: 4,
            ),
          );
        });

        if (currentPos != null) {
          cameraToPos(currentPos!);
        }
      } else {
        print("User document does not exist."); // Debugging output
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User location not found")),
        );
      }
    } catch (e) {
      print("Error fetching user data: $e"); // Debugging output
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Error fetching user data: $e")), // Show the actual error
      );
    }
  }

  Future<void> cameraToPos(LatLng pos) async {
    try {
      final GoogleMapController controller = await mapController.future;
      CameraPosition newCameraPos = CameraPosition(target: pos, zoom: 13);
      await controller
          .animateCamera(CameraUpdate.newCameraPosition(newCameraPos));
    } catch (e) {
      print("Error moving camera: $e");
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
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: currentPos!,
                ),
                if (startPos != null)
                  Marker(
                    markerId: const MarkerId("startLocation"),
                    position: startPos!,
                    infoWindow: const InfoWindow(title: "Start Location"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                if (endPos != null)
                  Marker(
                    markerId: const MarkerId("endLocation"),
                    position: endPos!,
                    infoWindow: const InfoWindow(title: "End Location"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
              polylines: _polylines,
            ),
    );
  }
}
