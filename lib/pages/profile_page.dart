import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  XFile? _image;
  bool _isUploading = false;
  String? _imageUrl;

  final String cloudName = 'dgif4h8fi';
  final String apiSecret = '7THw4n-xNXmkws1QemKGbgXwwVI';
  final String apiKey = '798453139952754';

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    setState(() {
      _isUploading = true;
    });

    try {
      final uri =
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'vinove_preset'
        ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (data['secure_url'] != null) {
        setState(() {
          _imageUrl = data['secure_url'];
        });
        return data['secure_url'];
      } else {
        print('Error uploading image: ${data['error']}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String gender = _genderController.text.trim();
    String phone = _phoneController.text.trim();

    if (fullName.isEmpty || email.isEmpty || gender.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Fields cannot be empty")));
      return;
    }
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("User not logged in")));
        return;
      }

      String? photoUrl = await _uploadImage();

      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userRef.set({
        'fullName': fullName,
        'email': email,
        'gender': gender,
        'phone': phone,
        'profileImage': photoUrl ?? _imageUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")));
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error saving profile")));
    }
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (snapshot.exists) {
      setState(() {
        _fullNameController.text = snapshot['fullName'] ?? '';
        _emailController.text = snapshot['email'] ?? '';
        _genderController.text = snapshot['gender'] ?? '';
        _phoneController.text = snapshot['phone'] ?? '';
        _imageUrl = snapshot['profileImage'];
      });
    }
  }

  void _removeImage() async {
    setState(() {
      _image = null;
      _imageUrl = null;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImage': FieldValue.delete()});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image removed successfully")),
        );
      } catch (e) {
        print('Error removing image from Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error removing profile image")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page",
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _image == null && (_imageUrl == null || _imageUrl!.isEmpty)
                            ? const AssetImage('assets/images/default_profile.png')
                            : (_image != null
                            ? FileImage(File(_image!.path))
                            : NetworkImage(_imageUrl!)) as ImageProvider,
                      ),

                      if (_isUploading) const CircularProgressIndicator(),
                      if (_image != null || _imageUrl != null)
                        Positioned(
                          top: 70,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.black),
                            onPressed: _removeImage,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.black, size: 30),
                  ),
                  enabled: false,// enabled: false,
                ),

                const SizedBox(height: 10),
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person, color: Colors.black, size: 30),
                    suffixIcon: Icon(Icons.edit, color: Colors.black, size: 20),
                  ),
                ),



                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone, color: Colors.black, size: 30),
                    suffixIcon: Icon(Icons.edit, color: Colors.black, size: 20),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Restrict to digits only
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number cannot be empty';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null; // Input is valid
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _genderController,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.transgender_sharp, color: Colors.black, size: 30),
                    // suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.black),

                  ),
                ),
                const SizedBox(height: 120),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  ),

                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}