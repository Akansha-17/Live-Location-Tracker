import 'dart:async';
import 'package:assignment/pages/user_detail_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assignment/pages/map_page.dart';
import 'package:assignment/pages/customDrawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  Timer? _timer;
  String? profileImage;
  String? fullName;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _initializeDailyLocation();
    _startTrackingLocation();
    _fetchUserData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permission is denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
          "Location permission is permanently denied. Please enable it in the app settings.");
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      debugPrint("Location permission granted.");
      await _initializeDailyLocation();
    }
  }

  Future<void> _initializeDailyLocation() async {
    try {
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user!.uid);

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final userData = await userDoc.get();
        final lastRecordedDate = userData.data()?['dailyLocation']?['date'];

        if (lastRecordedDate == null ||
            (lastRecordedDate is Timestamp &&
                lastRecordedDate.toDate().isBefore(today))) {
          final position = await Geolocator.getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.high));

          await userDoc.update({
            'dailyLocation': {
              'date': Timestamp.fromDate(today),
              'startPoint': {
                'lat': position.latitude,
                'lng': position.longitude,
                'timestamp': Timestamp.fromDate(now),
              },
              'endPoint': {
                'lat': position.latitude,
                'lng': position.longitude,
                'timestamp': Timestamp.fromDate(now),
              },
              'locations': [],
            },
          });
          debugPrint("Daily location reset for the new day.");
        }
      }
    } catch (e) {
      debugPrint("Error resetting daily location: $e");
    }
  }

  void _startTrackingLocation() {
    _timer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await _updateLocation();
    });
  }

  Future<void> _updateLocation() async {
    try {
      // Get the current location of the user
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Set a minimum distance filter
        ),
      );

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final userData = await userDoc.get();

      if (userData.exists) {
        // Get the last recorded location (endPoint) from Firestore
        final lastLocation = userData['dailyLocation']['endPoint'];
        final now = DateTime.now();

        // Calculate the distance between the current position and the last recorded position
        final distance = Geolocator.distanceBetween(
          lastLocation['lat'], // Last recorded latitude
          lastLocation['lng'], // Last recorded longitude
          position.latitude, // Current latitude
          position.longitude, // Current longitude
        );

        // If the distance is greater than 50 meters, update the location
        if (distance >= 50) {
          // Update the Firestore with the new location
          await userDoc.update({
            'dailyLocation.locations': FieldValue.arrayUnion([
              {
                'lat': position.latitude,
                'lng': position.longitude,
                'timestamp': Timestamp.fromDate(now),
              },
            ]),
            'dailyLocation.endPoint': {
              'lat': position.latitude,
              'lng': position.longitude,
              'timestamp': Timestamp.fromDate(now),
            },
          });

          debugPrint(
              "Location updated: ${position.latitude}, ${position.longitude}");
        } else {
          debugPrint(
              "No significant movement detected. Distance: $distance meters");
        }
      }
    } catch (e) {
      debugPrint("Error updating location: $e");
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "N/A";
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) {
      var userData = doc.data();
      userData['id'] = doc.id;
      return userData;
    }).toList();
  }

  Future<void> _fetchUserData() async {
    try {
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user!.uid);
        final userData = await userDoc.get();
        setState(() {
          fullName = userData.data()?['fullName'] ?? "No Name";
          profileImage = userData.data()?['profileImage'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  void signUserOut() {
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendify",
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: const CustomDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No users found.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final users = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    child: Container(
                      color: Colors.black12,
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 10, height: 50),
                          const CircleAvatar(
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.graphic_eq,
                                color: Colors.deepPurple),
                          ),
                          const SizedBox(width: 25),
                          Text(
                            "Attendance",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index];
                    final documentId = userData['id'];
                    final fullName = userData['fullName'] ?? "Unknown User";
                    final profileImage = userData['profileImage'];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profileImage != null
                              ? NetworkImage(profileImage)
                              : null,
                          child: profileImage == null
                              ? const Icon(Icons.person, color: Colors.black)
                              : null,
                        ),
                        title: Text(
                          fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.arrow_upward,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(userData['dailyLocation']
                                  ?['startPoint']?['timestamp']),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_downward,
                                size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(userData['dailyLocation']
                                  ?['endPoint']?['timestamp']),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.location_on, size: 24),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailMap(userId: documentId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapPage()),
            );
          },
          backgroundColor: Colors.black,
          label: Row(
            children: [
              const Icon(Icons.location_on, size: 24, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                "Map",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          )),
    );
  }
}


// not working


// Future<void> _saveDailyTravelHistory() async {
//   try {
//     if (user != null) {
//       final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
//
//       final userData = await userDoc.get();
//       final dailyLocation = userData.data()?['dailyLocation'];
//
//       if (dailyLocation != null) {
//         final date = dailyLocation['date'];
//         final formattedDate = DateFormat('yyyy-MM-dd').format(date.toDate());
//
//         await userDoc.update({
//           'travelHistory.$formattedDate': {
//             'date': date,
//             'startPoint': dailyLocation['startPoint'],
//             'endPoint': dailyLocation['endPoint'],
//             'locations': dailyLocation['locations'],
//           }
//         });
//
//         debugPrint("Daily travel history saved for $formattedDate.");
//       }
//     }
//   } catch (e) {
//     debugPrint("Error saving daily travel history: $e");
//   }
// }