import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:word/home.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _selectedRole = 'client';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _profilePictureURL = '';
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickProfilePicture() async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profilePictureURL = pickedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Register',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Colors.amberAccent,
              Colors.amber,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      ClipOval(
                        child: Image.asset(
                          'assets/logo.jpg',
                          width: 120,
                          height: 120,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Enter your Email, Password, and other details to Register',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      // Add button to pick profile picture
                      ElevatedButton(
                        onPressed: _pickProfilePicture,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                        ),
                        child: const Text(
                          'Pick Profile Picture',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Display selected profile picture path
                      Text(
                        _profilePictureURL,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          String email = _emailController.text.trim();
                          String password = _passwordController.text.trim();
                          String confirmPassword =
                              _confirmPasswordController.text.trim();
                          String name = _nameController.text.trim();

                          // Check if the password meets the minimum length requirement
                          if (password.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Password should be at least 6 characters'),
                                duration: Duration(seconds: 5),
                              ),
                            );
                            return;
                          }

                          if (password != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                                duration: Duration(seconds: 5),
                              ),
                            );
                            return;
                          }

                          try {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            UserCredential userCredential =
                                await _auth.createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            if (_profilePictureURL.isNotEmpty) {
                              Reference storageReference =
                                  FirebaseStorage.instance.ref().child(
                                      'profile_pictures/${userCredential.user!.uid}');
                              UploadTask uploadTask = storageReference
                                  .putFile(File(_profilePictureURL));
                              await uploadTask.whenComplete(() async {
                                _profilePictureURL =
                                    await storageReference.getDownloadURL();
                              });
                            }

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userCredential.user!.uid)
                                .set({
                              'name': name,
                              'profilePicture': _profilePictureURL,
                              'role': _selectedRole,
                            });

                            // Navigator.pop(context);
                            Navigator.pop(context);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeApp()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registration Successful'),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            // Handle specific Firebase Authentication exceptions
                            String errorMessage = 'An error occurred';
                            if (e.code == 'weak-password') {
                              errorMessage =
                                  'Password should be at least 6 characters';
                            } else if (e.code == 'email-already-in-use') {
                              errorMessage =
                                  'The account already exists for that email';
                            }

                            print('Registration failed: $errorMessage');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          } catch (e) {
                            print('Registration failed: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('An unexpected error occurred'),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
