import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

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
  List<Map<String, dynamic>> visitedLocations = [];
  Map<String, String> addressCache = {}; // Cache for geocoded addresses
  String currentDate = ""; // To store the current date fetched from Firestore
  double totalDistance = 0.0; // To store the total distance

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

      // Validate and parse dailyLocation and date
      final dailyLocation = data?['dailyLocation'] as Map<String, dynamic>?;
      if (dailyLocation == null || !dailyLocation.containsKey('date')) {
        throw Exception("Daily location or date data is missing.");
      }

      // Fetch and format the date field
      final fetchedDate = dailyLocation['date'];
      String formattedDate = "";
      if (fetchedDate is Timestamp) {
        formattedDate =
            DateFormat("E, MMM dd yyyy").format(fetchedDate.toDate());
      } else if (fetchedDate is String) {
        formattedDate =
            DateFormat("E, MMM dd yyyy").format(DateTime.parse(fetchedDate));
      } else {
        throw Exception("Invalid date format.");
      }

      // Parse startPoint, endPoint, and locations
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
        currentDate = formattedDate;
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

        // Add intermediate markers and collect data
        visitedLocations = locations;
        for (int i = 0; i < locations.length; i++) {
          final loc = locations[i];
          if (loc.containsKey('lat') && loc.containsKey('lng')) {
            final lat = loc['lat'];
            final lng = loc['lng'];
            _getAddress(lat, lng).then((address) {
              _markers.add(
                Marker(
                  markerId: MarkerId("location_$i"),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(
                    title: address,
                    snippet: "Visited: ${_formatTimestamp(loc['timestamp'])}",
                  ),
                ),
              );
              setState(() {});
            });
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

        // Calculate total distance
        totalDistance = calculateTotalDistance(locations);
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

  Future<String> _getAddress(double lat, double lng) async {
    final cacheKey = "$lat,$lng";
    if (addressCache.containsKey(cacheKey)) {
      return addressCache[cacheKey]!;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        addressCache[cacheKey] = address;
        return address;
      }
    } catch (e) {
      debugPrint("Geocoding failed for $lat,$lng: $e");
    }

    final fallback = "Lat: $lat, Lng: $lng";
    addressCache[cacheKey] = fallback;
    return fallback;
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown time";
    final DateTime dateTime = timestamp.toDate();
    return DateFormat("hh:mm a").format(dateTime);
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

  double calculateTotalDistance(List<Map<String, dynamic>> locations) {
    double total = 0.0;
    for (int i = 0; i < locations.length - 1; i++) {
      LatLng start = LatLng(locations[i]['lat'], locations[i]['lng']);
      LatLng end = LatLng(locations[i + 1]['lat'], locations[i + 1]['lng']);
      total += haversine(start, end);
    }
    return total;
  }

  double haversine(LatLng start, LatLng end) {
    const radius = 6371; // Radius of the Earth in km
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radius * c; // Returns the distance in kilometers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          currentPos == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            onMapCreated: (GoogleMapController controller) =>
                mapController.complete(controller),
            initialCameraPosition:
            CameraPosition(target: currentPos!, zoom: 13),
            markers: _markers,
            polylines: _polylines,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Sites: ${visitedLocations.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Distance: ${totalDistance.toStringAsFixed(2)} km",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            currentDate,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: visitedLocations.length,
                        itemBuilder: (context, index) {
                          final loc = visitedLocations[index];
                          final lat = loc['lat'];
                          final lng = loc['lng'];
                          final time = _formatTimestamp(loc['timestamp']);

                          return FutureBuilder<String>(
                            future: _getAddress(lat, lng),
                            builder: (context, snapshot) {
                              final address = snapshot.data ?? "Loading...";
                              return ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(address),
                                subtitle: Text("Time: $time"),
                                onTap: () {
                                  cameraToPos(LatLng(lat, lng));
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}