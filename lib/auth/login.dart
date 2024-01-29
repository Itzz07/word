import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:word/auth/register.dart';
import 'package:word/auth/forgotPassword.dart';
import 'package:word/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if the user is already signed in
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    await Future.delayed(Duration.zero); // Add this line

    User? user = _auth.currentUser;
    if (user != null) {
      // User is already signed in, navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeApp(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Log In',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
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
                        'Please Enter your Credentials to login.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage()),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          String email = _emailController.text.trim();
                          String password = _passwordController.text.trim();

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

                            await _auth.signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            // Dismiss the loading indicator
                            Navigator.pop(context);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeApp(),
                              ),
                            );
                            // Navigate to the home page or another screen on successful login
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Login Successfully'),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          } catch (e) {
                            print('Login failed: $e');

                            // Handle specific error cases
                            String errorMessage = 'An error occurred';
                            if (e is FirebaseAuthException) {
                              if (e.code == 'invalid-credential') {
                                errorMessage = 'auth credential is incorrect';
                              } else if (e.code == 'too-many-requests') {
                                errorMessage =
                                    'Too many requests, Try again later!';
                              } else {
                                // Handle other FirebaseAuthException cases if needed
                              }
                            }

                            // Dismiss the loading indicator
                            Navigator.pop(context);

                            // Show error message to the user
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                duration: const Duration(seconds: 5),
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
                          'Log In',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 20, // Text size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle sign up action here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationPage()),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
