import 'package:assignment/pages/aboutPage.dart';
import 'package:assignment/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:assignment/pages/home_page.dart';
import 'package:assignment/pages/members.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  String? profileImage;
  String? fullName;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
    return Drawer(
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
              accountName: Text(fullName ?? "No Name"),
              accountEmail: Text(user?.email ?? "No Email"),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    profileImage != null ? NetworkImage(profileImage!) : null,
                child: profileImage == null
                    ? const Icon(Icons.person, size: 40, color: Colors.black)
                    : null,
              ),
              decoration: const BoxDecoration(color: Colors.black87),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.abc_outlined),
            title: const Text("About"),
            onTap: () {
              // Navigate to the AttendancePage when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AboutPage(), // Make sure this is the correct page
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text("Members"),
            onTap: () {
              // Navigate to the AttendancePage when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsSection(
                    users: [],
                  ), // Make sure this is the correct page
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.graphic_eq),
            title: const Text("Attendance"),
            onTap: () {
              // Navigate to the AttendancePage when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomePage(), // Make sure this is the correct page
                ),
              );
            },
          ),
          //
          // const ListTile(
          //   leading: Icon(Icons.timeline),
          //   title: Text("Timelines"),
          // ),

          // const ListTile(
          //   leading: Icon(Icons.schedule),
          //   title: Text("Schedule"),
          // ),
          //
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text("Update Profile"),
            onTap: () {
              // Navigate to the ProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: signUserOut,
          ),

          Divider(
            thickness: 0.7,
            color: Colors.grey[400],
          ),

          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text("FAQ & Help"),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text("Privacy Policy"),
          ),
          const ListTile(
            leading: Icon(Icons.update),
            title: Text("Version: 3.11.4"),
          ),
        ],
      ),
    );
  }
}
