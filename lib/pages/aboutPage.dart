import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assignment/pages/customDrawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

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
      body: Container(
        color: Colors.white, // Set the background color to white
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // All Members Header Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 10, height: 50),
                    const CircleAvatar(
                      backgroundColor: Color.fromARGB(31, 119, 119, 119),
                      child: Icon(Icons.group,
                          color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "About App",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Image Section
              Center(
                child: Column(
                  children: [
                    Divider(
                      thickness: 0.7,
                      color: Colors.grey[400],
                    ),
                    Image.asset(
                      'assets/images/abm3.png',
                      height: 350,
                      width: 650,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/images/abmn2.png',
                      height: 350,
                      width: 650,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/images/abmn3.png',
                      height: 350,
                      width: 650,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/images/abm4.png',
                      height: 350,
                      width: 650,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),

              // Contact Us Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'For more information about our services, please reach out to us at:\n\n'
                      'Email: contact@vinove.com\n'
                      'Phone: +1 (123) 456-7890\n'
                      'Website: www.vinove.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
