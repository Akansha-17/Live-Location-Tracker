// import 'package:assignment/pages/user_detail_map.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart'; // Import for location
// import 'map_page.dart'; // Import MapPage if needed

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final user = FirebaseAuth.instance.currentUser; // Get the current user

//   void signUserOut() {
//     FirebaseAuth.instance.signOut();
//   }

//   // Fetching users by document ID
//   Future<List<Map<String, dynamic>>> fetchUsers() async {
//     final snapshot = await FirebaseFirestore.instance.collection('users').get();

//     return snapshot.docs.map((doc) {
//       // Get the document data and include the document ID
//       var userData = doc.data() as Map<String, dynamic>;
//       userData['id'] = doc.id; // Add the document ID to the data
//       return userData;
//     }).toList();
//   }

//   // Get current location and update database
//   Future<void> _updateUserLocation() async {
//     try {
//       bool permissionGranted = await _requestLocationPermission();

//       if (!permissionGranted) return;

//       // Define location settings
//       LocationSettings locationSettings = const LocationSettings(
//         accuracy: LocationAccuracy.high, // Set the desired accuracy
//         distanceFilter: 10, // Minimum distance in meters to trigger updates
//       );

//       // Get the current location
//       Position position = await Geolocator.getCurrentPosition(
//           locationSettings: locationSettings);

//       // Update Firestore with the current location, using dynamic UID
//       if (user != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user!.uid) // Use dynamic user UID
//             .update({
//           'lat': position.latitude,
//           'lng': position.longitude,
//           'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location updated successfully!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User not logged in')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update location: $e')),
//       );
//     }
//   }

//   // Location Permission and Service Check
//   Future<bool> _requestLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Location services are disabled. Please enable them.'),
//         ),
//       );
//       return false;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permissions are denied')),
//         );
//         return false;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Location permissions are permanently denied. Enable them in settings.',
//           ),
//         ),
//       );
//       return false;
//     }

//     return true;
//   }

//   // Footer to show map and update location
//   Widget _buildFooter() {
//     return BottomAppBar(
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: GestureDetector(
//           onTap: () async {
//             await _updateUserLocation(); // Update location before navigating
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const MapPage()),
//             );
//           },
//           child: const Text(
//             'Show on Map',
//             style: TextStyle(
//               color: Colors.deepPurple,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Attendance"),
//         backgroundColor: Colors.deepPurple,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: signUserOut,
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         // List fetched based on document ID
//         future: fetchUsers(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No users found."));
//           }

//           final users = snapshot.data!;

//           return ListView.builder(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               final userData = users[index];
//               final documentId = userData['id']; // Access the document ID here
//               final name = userData['firstName'] ?? "Unknown User";
//               final checkIn = userData['checkIn'] ?? "N/A";
//               final checkOut = userData['checkOut'] ?? "N/A";

//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.deepPurple,
//                     child: const Icon(Icons.person, color: Colors.white),
//                   ),
//                   title: Text(
//                     name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.arrow_upward,
//                               color: Colors.green, size: 16),
//                           const SizedBox(width: 5),
//                           Text(checkIn),
//                           const SizedBox(width: 10),
//                           const Icon(Icons.arrow_downward,
//                               color: Colors.red, size: 16),
//                           const SizedBox(width: 5),
//                           Text(checkOut),
//                         ],
//                       ),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.my_location, color: Colors.blue),
//                     onPressed: () async {
//                       await _updateUserLocation(); // Trigger location update on click
//                     },
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => UserDetailMap(
//                           userId: documentId, // Passing the document ID here
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       bottomNavigationBar: _buildFooter(), // Footer with "Show on Map"
//     );
//   }
// }

import 'dart:async';
import 'package:assignment/pages/user_detail_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  Timer? _timer;
  DateTime? _lastRecordedTime;

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationTracking() async {
    await _checkPermissionsAndRequest();
    await _checkGpsAndEnable();
    if (user != null) {
      _initializeUserLocationData();
      _startTrackingLocation();
    }
  }

  Future<void> _checkPermissionsAndRequest() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.locationWhenInUse.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        debugPrint("Location permissions denied.");
        return;
      }
    }
    debugPrint("Location permissions granted.");
  }

  Future<void> _checkGpsAndEnable() async {
    bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isGpsEnabled) {
      await Geolocator.openLocationSettings();
      isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isGpsEnabled) {
        debugPrint("GPS not enabled.");
        return;
      }
    }
    debugPrint("GPS is enabled.");
  }

  Future<void> _initializeUserLocationData() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final userData = await userDoc.get();

      if (userData.exists && userData.data()?['dailyLocation'] == null) {
        // Initialize `startPoint` and `endPoint` if not already present.
        await userDoc.set({
          'dailyLocation': {
            'startPoint': {
              'lat': position.latitude,
              'lng': position.longitude,
              'timestamp': Timestamp.fromDate(DateTime.now()),
            },
            'endPoint': {
              'lat': position.latitude,
              'lng': position.longitude,
              'timestamp': Timestamp.fromDate(DateTime.now()),
            },
            'locations': [],
          },
        }, SetOptions(merge: true));
        debugPrint("User location data initialized.");
      }
    } catch (e) {
      debugPrint("Error initializing user location data: $e");
    }
  }

  void _startTrackingLocation() async {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _updateLocation();
    });
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      final now = DateTime.now();
      if (_lastRecordedTime == null ||
          now.difference(_lastRecordedTime!).inMinutes >= 1) {
        _lastRecordedTime = now;

        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user!.uid);
        final userData = await userDoc.get();

        if (userData.exists) {
          final lastLocation = userData['dailyLocation']['endPoint'];
          final distance = Geolocator.distanceBetween(
            lastLocation['lat'],
            lastLocation['lng'],
            position.latitude,
            position.longitude,
          );

          if (distance > 50) {
            // Update only if moved more than 50 meters.
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
                'Location updated: ${position.latitude}, ${position.longitude}');
          } else {
            debugPrint('No significant movement detected.');
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) {
      var userData = doc.data();
      userData['id'] = doc.id;
      return userData;
    }).toList();
  }

  void signUserOut() {
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signUserOut,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index];
              final documentId = userData['id'];
              final name = userData['firstName'] ?? "Unknown User";
              final locations = userData['dailyLocation']?['locations'] ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Recent Locations:"),
                      ...locations.map<Widget>((location) {
                        final timestamp = location['timestamp']?.toDate();
                        return Text(
                          "Lat: ${location['lat']}, Lng: ${location['lng']}, Time: ${timestamp ?? 'N/A'}",
                          style: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ],
                  ),
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
          );
        },
      ),
    );
  }
}





// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final user = FirebaseAuth.instance.currentUser!;

//   void signUserOut() {
//     FirebaseAuth.instance.signOut();
//   }

//   Future<List<Map<String, dynamic>>> fetchUsers() async {
//     final snapshot = await FirebaseFirestore.instance.collection('users').get();
//     return snapshot.docs
//         .map((doc) => doc.data() as Map<String, dynamic>)
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Attendance"),
//         backgroundColor: Colors.deepPurple,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: signUserOut,
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: fetchUsers(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No users found."));
//           }

//           final users = snapshot.data!;

//           return ListView.builder(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               final userData = users[index];
//               final name = userData['firstName'] ?? "Unknown User";
//               // final id = userData['id'] ?? "N/A";
//               final checkIn = userData['checkIn'] ?? "N/A";
//               final checkOut = userData['checkOut'] ?? "N/A";

//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.deepPurple,
//                     child: Icon(Icons.person, color: Colors.white),
//                   ),
//                   title: Text(
//                     name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Text("ID: $id"),
//                       Row(
//                         children: [
//                           const Icon(Icons.arrow_upward,
//                               color: Colors.green, size: 16),
//                           const SizedBox(width: 5),
//                           Text(checkIn),
//                           const SizedBox(width: 10),
//                           const Icon(Icons.arrow_downward,
//                               color: Colors.red, size: 16),
//                           const SizedBox(width: 5),
//                           Text(checkOut),
//                         ],
//                       ),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.calendar_month_outlined,
//                             color: Colors.black),
//                         onPressed: () {
//                           // Handle calendar action
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.my_location, color: Colors.blue),
//                         onPressed: () {
//                           // Handle location action
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Attendance",
//           style: TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.deepPurple,
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//         actionsIconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//       ),
//       drawer: const NavigationDrawer(),
//       body: Column(
//         children: [
//           const CustomTile(),
//           const DateSelector(),
//           Expanded(child: AttendancePage()), // Main content area
//           const LocationFooter(), // Directly add the footer widget
//         ],
//       ),
//     );
//   }
// }

// class NavigationDrawer extends StatelessWidget {
//   const NavigationDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           const DrawerHeader(
//             decoration: BoxDecoration(color: Colors.deepPurple),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundImage:
//                       NetworkImage('https://via.placeholder.com/150'),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "Jyotsna Mishra",
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//                 Text(
//                   "jyotsnamishra@gmail.com",
//                   style: TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.checklist),
//             title: const Text("Attendance"),
//             onTap: () {
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.schedule),
//             title: const Text("Schedules"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SchedulesPage()),
//               );
//             },
//           ),
//           const ListTile(
//             leading: Icon(Icons.password),
//             title: Text("Change Password"),
//           ),
//           const ListTile(
//             leading: Icon(Icons.graphic_eq),
//             title: Text("Activity"),
//           ),
//           const ListTile(
//             leading: Icon(Icons.logout),
//             title: Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AttendancePage extends StatelessWidget {
//   final List<Map<String, String>> members = [
//     {
//       "name": "Aman Kumar",
//       "id": "Ak0003",
//       "checkIn": "09:30 AM",
//       "checkOut": "06:40 PM",
//       "status": "Working",
//       "image": "images/My image.jpg"
//     },
//     {
//       "name": "Saurabh Kumar",
//       "id": "SKL0034",
//       "checkIn": "10:00 AM",
//       "checkOut": "07:00 PM",
//       "status": "Not Logged In",
//       "image": "images/Saurabh.jpg"
//     },
//     {
//       "name": "Akansha",
//       "id": "AC0054",
//       "checkIn": "8:00 AM",
//       "checkOut": "5:00 PM",
//       "status": "Not Logged In Yet",
//       "image": "images/Akansha.jpg",
//     },
//     {
//       "name": "Shruti Tiwari",
//       "id": "STL0056",
//       "checkIn": "8:30 AM",
//       "checkOut": "6:30 PM",
//       "status": "Not Logged In Yet",
//       "image": "images/Shruti.jpg"
//     },
//     {
//       "name": "Utkarsh",
//       "id": "UP0050",
//       "checkIn": "11:00 AM",
//       "checkOut": "6:00 PM",
//       "status": "Not Logged In Yet",
//       "image": "images/utkarshp.jpg"
//     },
//     {
//       "name": "Manasvini Devgan",
//       "id": "MD0070",
//       "checkIn": "12:00 PM",
//       "checkOut": "10:00 PM",
//       "status": "Not Logged In Yet",
//       "image": "https://via.placeholder.com/150"
//     },
//     {
//       "name": "Manav Das",
//       "id": "MD0090",
//       "checkIn": "10:30 AM",
//       "checkOut": "7:00 PM",
//       "status": "Not Logged In Yet",
//       "image": "images/manavd.jpg"
//     },
//     {
//       "name": "Shuvina",
//       "id": "SR0080",
//       "checkIn": "10:00 AM",
//       "checkOut": "6:00 PM",
//       "status": "Not Logged In Yet",
//       "image": "images/Shuvina.jpg"
//     },
//   ];

//   AttendancePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(10),
//       itemCount: members.length,
//       itemBuilder: (context, index) {
//         return Card(
//           elevation: 3,
//           margin: const EdgeInsets.symmetric(vertical: 2),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundImage: members[index]['image']!.startsWith('http')
//                   ? NetworkImage(members[index]['image']!)
//                   : AssetImage(members[index]['image']!),
//             ),
//             title: Text(
//               members[index]['name']!,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("ID: ${members[index]['id']}"),
//                 Row(
//                   children: [
//                     const Icon(Icons.arrow_upward,
//                         color: Colors.green, size: 16),
//                     const SizedBox(width: 5),
//                     Text(members[index]['checkIn']!),
//                     const SizedBox(width: 10),
//                     const Icon(Icons.arrow_downward,
//                         color: Colors.red, size: 16),
//                     const SizedBox(width: 5),
//                     Text(members[index]['checkOut']!),
//                   ],
//                 ),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.calendar_month_outlined,
//                       color: Colors.black),
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text(
//                           "${members[index]['name']}'s attendance marked!"),
//                     ));
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.my_location, color: Colors.blue),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const LocationFooter(),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class CustomTile extends StatelessWidget {
//   const CustomTile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.grey[200],
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.deepPurple,
//                 child: Icon(Icons.group, color: Colors.white),
//               ),
//               SizedBox(width: 10),
//               Text(
//                 "All Members",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           TextButton(
//             onPressed: () {},
//             child: const Text(
//               "Change",
//               style: TextStyle(
//                 color: Colors.blue,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DateSelector extends StatelessWidget {
//   const DateSelector({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white60,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.chevron_left),
//               ),
//               const Text(
//                 "Tue, Aug 31 2022",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.chevron_right),
//               ),
//             ],
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.calendar_today),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class LocationFooter extends StatelessWidget {
//   const LocationFooter({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             "Show Map View",
//             style: TextStyle(
//               color: Colors.blue,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           IconButton(
//             onPressed: () {
//               // Add functionality for map navigation
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Navigating to Map View...")),
//               );
//             },
//             icon: const Icon(
//               Icons.chevron_right,
//               color: Colors.blue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class SchedulesPage extends StatelessWidget {
//   const SchedulesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Schedules")),
//       body: const Center(child: Text("Schedules Page")),
//     );
//   }
// }
