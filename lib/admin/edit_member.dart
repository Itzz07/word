import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditMemberScreen extends StatefulWidget {
  final Map<String, dynamic> memberData;
  final String documentId;
  final bool isDarkMode;

  const EditMemberScreen({
    super.key,
    required this.memberData,
    required this.documentId,
    required this.isDarkMode,
  });

  @override
  _EditMemberScreenState createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  // Add TextEditingController for each field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  String _profilePictureURL = '';
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing member data
    _nameController.text = widget.memberData['name'];
    _positionController.text = widget.memberData['position'] ?? '';
    _emailController.text = widget.memberData['email'] ?? '';
    _whatsappController.text = widget.memberData['whatsapp'] ?? '';
    _roleController.text = widget.memberData['role'] ?? '';
    _profilePictureURL = widget.memberData['imageUrl'] ?? '';
  }

  bool isSuperuser() {
    return widget.memberData['role'] == 'superuser';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.orange : Colors.orangeAccent,
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
          'Edit Member',
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
                child: Form(
                  // Add a GlobalKey<FormState> for the form
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickProfilePicture();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.amber
                                  : Colors.amberAccent,
                              width: 2.0, // Set the width of the border
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: _profilePictureURL.isNotEmpty
                                ? (_profilePictureURL.startsWith('http')
                                    ? NetworkImage(_profilePictureURL)
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
                      // name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      // posiion
                      TextFormField(
                        controller: _positionController,
                        decoration: InputDecoration(
                          labelText: 'Position(Optional)',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      // email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      // whatsapp
                      TextFormField(
                        controller: _whatsappController,
                        decoration: InputDecoration(
                          labelText: 'WhatApp',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      // Add the DropdownButtonFormField for the role
                      // DropdownButtonFormField<String>(
                      //   dropdownColor:
                      //       isDarkMode ? Colors.orange : Colors.orangeAccent,
                      //   decoration: InputDecoration(
                      //     labelText: 'Role',
                      //     labelStyle: TextStyle(
                      //       color: isDarkMode ? Colors.white : Colors.black,
                      //     ),
                      //   ),
                      //   style: TextStyle(
                      //     color: isDarkMode ? Colors.white : Colors.black,
                      //   ),
                      //   value: _roleController.text,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _roleController.text = value!;
                      //     });
                      //   },
                      //   items: ['admin', 'client']
                      //       .map<DropdownMenuItem<String>>((String value) {
                      //     return DropdownMenuItem<String>(
                      //       value: value,
                      //       child: Text(value),
                      //     );
                      //   }).toList(),
                      //   // ... other properties
                      // ),
                      // Add a condition to show the DropdownButtonFormField only if not 'superuser'
                      // if (!isSuperuser())
                      //   DropdownButtonFormField<String>(
                      //     dropdownColor:
                      //         isDarkMode ? Colors.orange : Colors.orangeAccent,
                      //     decoration: InputDecoration(
                      //       labelText: 'Role',
                      //       labelStyle: TextStyle(
                      //         color: isDarkMode ? Colors.white : Colors.black,
                      //       ),
                      //     ),
                      //     style: TextStyle(
                      //       color: isDarkMode ? Colors.white : Colors.black,
                      //     ),
                      //     value: _roleController.text,
                      //     onChanged: (value) {
                      //       setState(() {
                      //         _roleController.text = value!;
                      //       });
                      //     },
                      //     items: ['admin', 'client']
                      //         .map<DropdownMenuItem<String>>((String value) {
                      //       return DropdownMenuItem<String>(
                      //         value: value,
                      //         child: Text(value),
                      //       );
                      //     }).toList(),
                      //     // ... other properties
                      //   ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _submitForm();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            isDarkMode ? Colors.orange : Colors.black,
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                isDarkMode ? Colors.black : Colors.orangeAccent,
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

  void _submitForm() async {
    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      // Get the updated values from the controllers
      String updatedName = _nameController.text;
      String updatedPosition = _positionController.text;
      String updatedEmail = _emailController.text;
      String updatedWhatsApp = _whatsappController.text;
      String updatedRole = _roleController.text;

      // Implement logic to update member details in the database
      try {
        // Initialize a map to store updated data
        Map<String, dynamic> updatedData = {
          'name': updatedName,
          'position': updatedPosition,
          'email': updatedEmail,
          'whatsapp': updatedWhatsApp,
          'role': updatedRole,
        };

        // Check if a new image is selected
        if (_profilePictureURL.isNotEmpty) {
          // Upload the new image to Firebase Storage
          String imageUrl = await _uploadImage();
          // Update the 'imageUrl' field in the Firestore document
          updatedData['imageUrl'] = imageUrl;
        }

        // Update the Firestore document with the updated data
        await FirebaseFirestore.instance
            .collection('members')
            .doc(widget.documentId)
            .update(updatedData);

        // Show a success message or navigate back to the previous screen
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Member details updated successfully!'),
          duration: Duration(seconds: 3),
        ));

        // You can navigate back to the previous screen if needed
        // Navigator.pop(context);
      } catch (e) {
        // Handle errors, e.g., show an error message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error updating member details. Please try again.'),
          duration: Duration(seconds: 3),
        ));
      }
    }
  }

  Future<String> _uploadImage() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('members_images')
          .child(widget.documentId) // Use documentId as the image filename
          .child(DateTime.now().toString());
      await storageRef.putFile(File(_profilePictureURL));
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _pickProfilePicture() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profilePictureURL = pickedFile.path;
      });
    }
  }
}
