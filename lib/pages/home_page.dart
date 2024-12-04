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
import 'package:google_fonts/google_fonts.dart';
import 'package:assignment/pages/map_page.dart'; // Assuming you have a MapPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeDailyLocation();
    _startTrackingLocation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final userData = await userDoc.get();

      if (userData.exists) {
        final lastLocation = userData['dailyLocation']['endPoint'];
        final now = DateTime.now();
        final distance = Geolocator.distanceBetween(
          lastLocation['lat'],
          lastLocation['lng'],
          position.latitude,
          position.longitude,
        );

        if (distance > 50) {
          await userDoc.update({
            'dailyLocation.locations': FieldValue.arrayUnion([
              {
                'lat': position.latitude,
                'lng': position.longitude,
                'timestamp': Timestamp.fromDate(now),
              }
            ]),
            'dailyLocation.endPoint': {
              'lat': position.latitude,
              'lng': position.longitude,
              'timestamp': Timestamp.fromDate(now),
            },
          });
          debugPrint(
              "Location updated: ${position.latitude}, ${position.longitude}");
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
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "No Name"),
              accountEmail: Text(user?.email ?? "No Email"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Icon(Icons.person, size: 40)
                    : null,
              ),
              decoration: BoxDecoration(color: Colors.blue),
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
              leading: Icon(Icons.logout),
              title: Text("Logout"),
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
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No users found.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          final users = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            children: [
              // New UI Block: "All Members" and Date Navigation
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    // Top row with "All Members" and "Change"
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
              // Existing ListView.builder
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = users[index];
                  final documentId = userData['id'];
                  final name = userData['firstName'] ?? "Unknown User";

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Icon(Icons.person,
                            color: Colors.deepPurple.shade600),
                      ),
                      title: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Transform.rotate(
                            angle: -0.5,
                            child: Icon(Icons.arrow_upward,
                                size: 16, color: Colors.green),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(userData['dailyLocation']
                                ?['startPoint']?['timestamp']),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Transform.rotate(
                            angle: 0.5,
                            child: Icon(Icons.arrow_downward,
                                size: 16, color: Colors.red),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(userData['dailyLocation']
                                ?['endPoint']?['timestamp']),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.location_on, size: 18),
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
            ],
          );
        },
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MapPage()), // Navigate to MapPage
          );
        },
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            "Show on Map",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}


// aman code ---------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firstpage.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: HomePageui(),
//     );
//   }
// }

// class HomePageui extends StatelessWidget {
//   const HomePageui({super.key});

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
//           const DateSelector(), // Calendar Section Added
//           Expanded(child: AttendancePage()), // Members List with attendance status
//           const LocationFooter(), // Footer for location
//         ],
//       ),
//     );
//   }
// }

// class NavigationDrawer extends StatelessWidget {
//   const NavigationDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser; // Get the current user

//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: const BoxDecoration(color: Colors.deepPurple),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                     backgroundImage: const AssetImage('images/Saurabh.jpg'),
//                   // backgroundImage: user?.photoURL != null
//                   //     ? NetworkImage(user!.photoURL!)
//                   //     : const NetworkImage('images/Saurabh.jpg'),
//                 ),
//                 const SizedBox(height: 10),
//                 // crossAxisAlignment: CrossAxisAlignment.start,
//                 Text(
//                   user?.displayName ?? 'No Name',
//                   style: const TextStyle(color: Colors.white, fontSize: 18),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   user?.email ?? 'No Email',
//                   style: const TextStyle(color: Colors.white70, fontSize: 14),
//                   overflow: TextOverflow.ellipsis,
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
//           const ListTile(
//             leading: Icon(Icons.schedule),
//             title: Text("Schedules"),
//           ),
//           if (user != null) ...[
//             ListTile(
//               leading: const Icon(Icons.account_circle),
//               title: Text("Logged in as: ${user.displayName ?? 'No Name'}"),
//             ),
//             ListTile(
//               leading: const Icon(Icons.email),
//               title: Text("Email: ${user.email ?? 'No Email'}"),
//             ),
//           ],
//           const ListTile(
//             leading: Icon(Icons.password),
//             title: Text("Change Password"),
//           ),
//           const ListTile(
//             leading: Icon(Icons.graphic_eq),
//             title: Text("Activity"),
//           ),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text("Logout"),
//             onTap: () async {
//               await FirebaseAuth.instance.signOut();
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => const FirstPage()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AttendancePage extends StatelessWidget {
  
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
//                   : AssetImage(members[index]['image']!) as ImageProvider,
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
//                     const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
//                     const SizedBox(width: 5),
//                     Text(members[index]['checkIn']!),
//                     const SizedBox(width: 10),
//                     const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
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
//                   icon: const Icon(Icons.calendar_month_outlined, color: Colors.black),
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text("${members[index]['name']}'s attendance marked!"),
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
//       color: Colors.blue,
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: const Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.location_on, color: Colors.white),
//           SizedBox(width: 8),
//           Text("View Location", style: TextStyle(color: Colors.white)),
//         ],
//       ),
//     );
//   }
// }





// ------------------------------------------------------------------




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
