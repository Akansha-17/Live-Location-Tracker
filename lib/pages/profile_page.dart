import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
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
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
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
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'profileImage': photoUrl ?? _imageUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")));
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error saving profile")));
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
        _firstNameController.text = snapshot['firstName'] ?? '';
        _lastNameController.text = snapshot['lastName'] ?? '';
        _emailController.text = snapshot['email'] ?? '';
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
          SnackBar(content: Text("Profile image removed successfully")),
        );
      } catch (e) {
        print('Error removing image from Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error removing profile image")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      backgroundImage: _image == null && _imageUrl == null
                          ? AssetImage('assets/images/default_profile.png')
                          : (_image != null
                              ? FileImage(File(_image!.path))
                              : NetworkImage(_imageUrl!)) as ImageProvider,
                    ),
                    if (_isUploading) CircularProgressIndicator(),
                    if (_image != null || _imageUrl != null)
                      Positioned(
                        top: 70,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: _removeImage,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                enabled: false,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
