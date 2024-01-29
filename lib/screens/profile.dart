import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final bool isDarkMode;

  const ProfilePage({super.key, required this.isDarkMode});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  String _profilePictureURL = '';
  final ImagePicker _imagePicker = ImagePicker();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the user data in the fields
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc['name'] ?? '';
        _profilePictureURL = userDoc['profilePicture'] ?? '';
      });
    }
  }

  Future<void> _pickProfilePicture() async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profilePictureURL = pickedImage.path;
      });
    }
  }

  Future<void> _updateProfile() async {
    String name = _nameController.text.trim();
    String uid = _auth.currentUser!.uid;

    try {
      // Update profile picture only if a new one is selected
      if (_profilePictureURL.isNotEmpty) {
        Reference storageReference =
            FirebaseStorage.instance.ref().child('profile_pictures/$uid');
        UploadTask uploadTask =
            storageReference.putFile(File(_profilePictureURL));
        await uploadTask.whenComplete(() async {
          _profilePictureURL = await storageReference.getDownloadURL();
        });
      }

      // Update user information in Firestore
      Map<String, dynamic> updateData = {'name': name};
      if (_profilePictureURL.isNotEmpty) {
        updateData['profilePicture'] = _profilePictureURL;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updateData);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile Updated Successfully'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Profile update failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while updating the profile'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.amber : Colors.amberAccent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipOval(
              child: Image.asset(
                isDarkMode ? 'assets/logo1.jpg' : 'assets/logo.jpg',
                height: 33,
                width: 33,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // GestureDetector(
                    //   onTap: _pickProfilePicture,
                    //   child: CircleAvatar(
                    //     radius: 80,
                    //   backgroundImage: _profilePictureURL.isNotEmpty
                    //       ? (_profilePictureURL.startsWith('http')
                    //           ? NetworkImage(_profilePictureURL)
                    //               as ImageProvider<Object>?
                    //           : FileImage(File(_profilePictureURL))
                    //               as ImageProvider<Object>?)
                    //       : AssetImage('assets/default_profile_picture.jpg')
                    //           as ImageProvider<Object>?,
                    // ),
                    // ),
                    GestureDetector(
                      onTap: _pickProfilePicture,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(
                            color:
                                isDarkMode ? Colors.amber : Colors.amberAccent,
                            width: 2.0, // Set the width of the border
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          //     backgroundImage: _profilePictureURL.isNotEmpty
                          //       ? (_profilePictureURL.startsWith('http')
                          //           ? NetworkImage(_profilePictureURL)
                          //               as ImageProvider<Object>?
                          //           : FileImage(File(_profilePictureURL))
                          //               as ImageProvider<Object>?)
                          //       : AssetImage('assets/default_profile_picture.jpg')
                          //           as ImageProvider<Object>?,
                          // ),
                          backgroundImage: _profilePictureURL.isNotEmpty
                              ? (_profilePictureURL.startsWith('http')
                                  ? NetworkImage(_profilePictureURL)
                                      as ImageProvider<Object>?
                                  : FileImage(File(_profilePictureURL))
                                      as ImageProvider<Object>?)
                              : AssetImage(
                                  isDarkMode
                                      ? 'assets/logo1.jpg'
                                      : 'assets/logo.jpg',
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'New Name',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          isDarkMode ? Colors.amber : Colors.black,
                        ),
                      ),
                      child: Text(
                        'Update Profile',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.amberAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Form(
                key: _formKey, // Add a GlobalKey<FormState> for the form
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Current Email: ${_auth.currentUser?.email ?? "N/A"}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Other form fields
                      TextFormField(
                        controller: _newEmailController,
                        decoration: InputDecoration(
                          labelText: 'New Email',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        obscureText: true,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // Validate the form before updating credentials
                          if (_formKey.currentState?.validate() ?? false) {
                            await _updateCredentials();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            isDarkMode ? Colors.amber : Colors.black,
                          ),
                        ),
                        child: Text(
                          'Update Credentials',
                          style: TextStyle(
                            color:
                                isDarkMode ? Colors.white : Colors.amberAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateCredentials() async {
    try {
      // Check if the new password and confirmation password match
      if (_newPasswordController.text != _confirmPasswordController.text) {
        print('Passwords do not match.');
        return;
      }

      // Ensure the form is valid before proceeding
      if (!_formKey.currentState!.validate() ?? false) {
        print('Form is not valid.');
        return;
      }

      // Ensure the user is signed in before updating credentials
      if (_auth.currentUser == null) {
        print('User not signed in.');
        return;
      }

      // Update email
      final newEmail = _newEmailController.text.trim();
      if (newEmail.isNotEmpty && newEmail != _auth.currentUser?.email) {
        await _auth.currentUser?.updateEmail(newEmail);
        print('Email updated successfully.');
      }

      // Update password
      final newPassword = _newPasswordController.text.trim();
      if (newPassword.isNotEmpty) {
        await _auth.currentUser?.updatePassword(newPassword);
        print('Password updated successfully.');
      }

      print('User updating credentials successfully.');
    } catch (e) {
      print('Error updating credentials: $e');
      // Handle errors (e.g., display error message to the user)
    }
  }
}
