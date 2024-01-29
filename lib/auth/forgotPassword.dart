import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

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
          'Forgot Password',
          style: TextStyle(
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
                        'Please Enter your Email to reset password.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () async {
                          String email = _emailController.text.trim();

                          try {
                            // Show a loading indicator while waiting for the authentication result
                            showDialog(
                              context: context,
                              barrierDismissible:
                                  false, // Prevent the user from dismissing the dialog
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                            await _auth.sendPasswordResetEmail(email: email);
                            // Dismiss the loading indicator
                            Navigator.pop(context);
                            // Show a success message or navigate to login page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Message Successfully Sent./nCheck your Email!'),
                                duration: Duration(seconds: 3),
                              ),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            print('Forgot password failed: $e');
                            // Handle forgot password failure (show error message, etc.)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Forgot password failed: $e'),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Background color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40), // Button size
                        ),
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 20, // Text size
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
