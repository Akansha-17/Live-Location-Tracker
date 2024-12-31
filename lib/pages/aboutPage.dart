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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vinove Logo (you can add an image or logo here)
            Center(
              child: Image.asset(
                'assets/images/about1.png', // Add the logo in your assets folder
                height: 596,
                width: 600,
              ),
            ),
            Center(
              child: Image.asset(
                'assets/images/about2.png', // Add the logo in your assets folder
                height: 230,
                width: 400,
              ),
            ),
            // Contact Information Section
            Container(
              color: Colors.white, // Set the background color to white
              padding: const EdgeInsets.all(16.0), // Add padding for spacing
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
    );
  }
}
