import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  LatLng? currentUserLocation; // Current user's location (nullable)
  Set<Marker> userMarkers = {}; // Store all user markers

  @override
  void initState() {
    super.initState();
    getCurrentUserLocation(); // Set up current user's location
    getUsersLocations(); // Fetch users' locations
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentUserLocation == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading until location is fetched
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) =>
                  mapController.complete(controller),
              initialCameraPosition: CameraPosition(
                target:
                    currentUserLocation!, // Set initial position to current user's location
                zoom: 13,
              ),
              markers: userMarkers, // Display all user markers
            ),
    );
  }

  // Fetch the current logged-in user's location
  Future<void> getCurrentUserLocation() async {
    // Get the current logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Get current location using Geolocator
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high, // Set desired accuracy
          distanceFilter: 10, // Distance filter for updates (optional)
        ),
      );

      // Set the current user location
      setState(() {
        currentUserLocation =
            LatLng(position.latitude, position.longitude); // Update location
      });
    }
  }

  // Fetch users' endpoint locations from Firestore and display them on the map
  Future<void> getUsersLocations() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var usersCollection = firestore.collection('users');
    var userDocs = await usersCollection.get();

    // Clear any existing markers before adding new ones
    Set<Marker> markers = {};

    for (var doc in userDocs.docs) {
      var userData = doc.data();
      if (userData['dailyLocation'] != null &&
          userData['dailyLocation']['endPoint'] != null) {
        double lat = userData['dailyLocation']['endPoint']['lat'];
        double lng = userData['dailyLocation']['endPoint']['lng'];
        String userId = doc.id;
        String firstName = userData['firstName'];
        String lastName = userData['lastName'];

        // Create a marker with a user icon and display the user's name in the info window
        final marker = Marker(
          markerId: MarkerId(userId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
              title: '$firstName $lastName'), // Show only user's name
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure), // Set a default user icon color
        );

        markers.add(marker); // Add the marker to the set
      }
    }

    setState(() {
      userMarkers = markers; // Update the state with new markers
    });
  }
}
