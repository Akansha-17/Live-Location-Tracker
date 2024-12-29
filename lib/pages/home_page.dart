import 'dart:async';
import 'package:assignment/pages/profile_page.dart';
import 'package:assignment/pages/user_detail_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assignment/pages/map_page.dart';
import 'package:intl/intl.dart';

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
  String? firstName;

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
        // Handle the case when permission is denied
        debugPrint("Location permission is denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case when permission is permanently denied
      debugPrint(
          "Location permission is permanently denied. Please enable it in the app settings.");
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      debugPrint("Location permission granted.");
      await _initializeDailyLocation(); // Proceed with your location logic
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
                const LocationSettings(accuracy: LocationAccuracy.high),
          );

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
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _updateLocation();
    });
  }

  Future<void> _saveDailyTravelHistory() async {
    try {
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user!.uid);

        final userData = await userDoc.get();
        final dailyLocation = userData.data()?['dailyLocation'];

        if (dailyLocation != null) {
          final date = dailyLocation['date'];
          final formattedDate = DateFormat('yyyy-MM-dd').format(date.toDate());

          await userDoc.update({
            'travelHistory.$formattedDate': {
              'date': date,
              'startPoint': dailyLocation['startPoint'],
              'endPoint': dailyLocation['endPoint'],
              'locations': dailyLocation['locations'],
            }
          });

          debugPrint("Daily travel history saved for $formattedDate.");
        }
      }
    } catch (e) {
      debugPrint("Error saving daily travel history: $e");
    }
  }

  Future<void> _updateLocation() async {
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
          // Save current day's data to history
          await _saveDailyTravelHistory();

          // Reset daily location
          final position = await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high),
          );

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
          firstName = userData.data()?['firstName'] ?? "No Name";
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
          "Attendance",
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue, // Blue color for AppBar
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the ProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
              child: UserAccountsDrawerHeader(
                accountName: Text(firstName ?? "No Name"),
                accountEmail: Text(user?.email ?? "No Email"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage:
                      profileImage != null ? NetworkImage(profileImage!) : null,
                  child: profileImage == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                decoration: const BoxDecoration(color: Colors.blue),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.graphic_eq),
              title: Text("Attendance"),
            ),
            const ListTile(
              leading: Icon(Icons.abc_outlined),
              title: Text("About"),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: signUserOut,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
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

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.group,
                                  color: Colors.blue.shade600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "All Members",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = users[index];
                  final documentId = userData['id'];
                  final firstName = userData['firstName'] ?? "Unknown User";
                  final profileImage =
                      userData['profileImage']; // Fetch profileImage from DB

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
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        firstName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Transform.rotate(
                            angle: -0.5,
                            child: const Icon(Icons.arrow_upward,
                                size: 16, color: Colors.green),
                          ),
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
                          Transform.rotate(
                            angle: 0.5,
                            child: const Icon(Icons.arrow_downward,
                                size: 16, color: Colors.red),
                          ),
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
                      trailing: const Icon(Icons.location_on, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailMap(
                              userId: documentId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 100), // Add space below the user list
            ],
          );
        },
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapPage()),
          );
        },
        child: Container(
          width: double.infinity,
          color: Colors.blue, // Blue background color for Bottom Sheet
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            "Show on Map",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
