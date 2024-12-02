import 'package:assignment/pages/auth_page.dart';
import 'package:assignment/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: GoogleFonts.lato().fontFamily),
      routes: {
        // "/": (context) => const LandingPage(),
        // "/": (context) => const AuthPage()
        "/": (context) => const MapPage()
      },
    );
  }
}

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
