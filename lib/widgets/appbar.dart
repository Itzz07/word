import 'dart:io';

import 'package:flutter/material.dart';
import 'package:word/auth/login.dart';
import 'package:word/screens/about.dart';
import 'package:word/admin/panel.dart';
import 'package:word/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onDarkModeToggle;
  final bool isDarkMode;

  const CustomAppBar(
      {super.key, required this.onDarkModeToggle, required this.isDarkMode});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
  @override
  Size get preferredSize => const Size.fromHeight(120.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _profilePictureURL = '';

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
        _profilePictureURL = userDoc['profilePicture'] ?? '';
      });
    }
  }

  // Adjust the height as needed
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.isDarkMode ? Colors.black87 : Colors.white,
      elevation: 0.0,
      flexibleSpace: ClipPath(
        clipper: CurveClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.isDarkMode ? Colors.amber : Colors.amberAccent,
                widget.isDarkMode ? Colors.black87 : Colors.white,
              ],
            ),
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
              color: widget.isDarkMode ? Colors.white : Colors.black,
              icon: widget.isDarkMode
                  ? const Icon(Icons.light_mode)
                  : const Icon(Icons.dark_mode),
              onPressed: widget.onDarkModeToggle,
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(isDarkMode: widget.isDarkMode),
                  ),
                );
                // After returning from ProfilePage, reload user data
                await _loadUserData();
                setState(() {});
              },
              child: Center(
                // Use the Center widget to center its child
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: _profilePictureURL.isNotEmpty
                        ? (_profilePictureURL.startsWith('http')
                            ? NetworkImage(_profilePictureURL)
                            : FileImage(File(_profilePictureURL))
                                as ImageProvider<Object>?)
                        : AssetImage(
                            widget.isDarkMode
                                ? 'assets/logo1.jpg'
                                : 'assets/logo.jpg',
                          ),
                    radius: 50, // Adjust the radius as needed
                  ),
                ),
              ),
            ),
            IconButton(
              color: widget.isDarkMode ? Colors.white : Colors.black,
              icon: const Icon(Icons.menu),
              onPressed: () => _showPopupMenu(context),
            ),
          ]),
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      // position: RelativeRect.fromRect(
      //   Rect.fromPoints(
      //     overlay.localToGlobal(overlay.size.topLeft(Offset.zero)),
      //     overlay.localToGlobal(overlay.size.bottomRight(Offset.zero)),
      //   ),
      //   Offset.zero & overlay.size,
      // ),
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          value: 'adminPanel',
          child: Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'Admin Panel',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'about',
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'About',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'Log Out',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
      color: widget.isDarkMode ? Colors.amber : Colors.amberAccent,
    ).then(
      (value) async {
        if (value == 'adminPanel') {
          FirebaseAuth auth = FirebaseAuth.instance;
          User? user = auth.currentUser;

          if (user != null) {
            // User is signed in, check if the user has admin role in Firestore
            FirebaseFirestore firestore = FirebaseFirestore.instance;

            firestore.collection('users').doc(user.uid).get().then((doc) {
              if (doc.exists) {
                // Check if the user has admin role
                if (doc['role'] == 'admin' || doc['role'] == 'superuser') {
                  // User has admin role, navigate to admin panel
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminPanelPage(isDarkMode: widget.isDarkMode),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Successfully accessed the menu item \nWELCOME TO THE ADMIN PANEL!'),
                      duration: Duration(seconds: 5),
                    ),
                  );
                } else {
                  // User doesn't have admin role
                  // You can show an error message or redirect to a different page
                  print('User does not have admin role');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'You do not have permission to access the selected menu item.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } else {
                // Handle the case where the user document does not exist
                print('User document does not exist');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your User document does not exist.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            });
          } else {
            // User is not signed in, handle as needed (e.g., show login screen)
            print('User is not signed in');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You\'re  not signed in.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else if (value == 'about') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AboutPage(isDarkMode: widget.isDarkMode),
            ),
          );
        } else if (value == 'logout') {
          // Perform logout when the user selects the 'logout' option
          _handleLogout();
        }
      },
    );
  }

//   void _handleLogout() async {
//     // Perform logout when the user selects the 'logout' option
//     await _auth.signOut();

//     // Navigate to the login or registration page after logout
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const LoginPage(),
//       ),
//     );
//   }
// }
  //   ).then((value) async {
  //     if (value == 'adminPanel') {
  //       // your admin panel logic
  //     } else if (value == 'about') {
  //       // your about logic
  //     } else if (value == 'logout') {
  //       // your logout logic
  //     }
  //   });
  // }

  void _handleLogout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:word/auth/login.dart';
// import 'package:word/screens/about.dart';
// import 'package:word/admin/panel.dart';
// import 'package:word/screens/profile.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class CurveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(0, size.height - 30);
//     path.quadraticBezierTo(
//         size.width / 2, size.height, size.width, size.height - 30);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }
// // class CurveClipper extends CustomClipper<Path> {
// //   @override
// //   Path getClip(Size size) {
// //     final path = Path();
// //     path.lineTo(0, size.height);
// //     path.quadraticBezierTo(
// //         size.width / 2, size.height - 30, size.width, size.height);
// //     path.lineTo(size.width, 0);
// //     path.close();
// //     return path;
// //   }

// //   @override
// //   bool shouldReclip(CustomClipper<Path> oldClipper) {
// //     return false;
// //   }
// // }
// // class CurveClipper extends CustomClipper<Path> {
// //   @override
// //   Path getClip(Size size) {
// //     final path = Path();
// //     path.lineTo(0, size.height - 30);
// //     path.quadraticBezierTo(
// //         size.width / 2, size.height + 30, size.width, size.height - 30);
// //     path.lineTo(size.width, 0);
// //     path.close();
// //     return path;
// //   }

// //   @override
// //   bool shouldReclip(CustomClipper<Path> oldClipper) {
// //     return false;
// //   }
// // }

// class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
//   final VoidCallback onDarkModeToggle;
//   final bool isDarkMode;

//   const CustomAppBar(
//       {super.key, required this.onDarkModeToggle, required this.isDarkMode});

//   @override
//   State<CustomAppBar> createState() => _CustomAppBarState();
//   @override
//   Size get preferredSize => const Size.fromHeight(120.0);
// }

// class _CustomAppBarState extends State<CustomAppBar> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String _profilePictureURL = '';

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the user data in the fields
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     String uid = _auth.currentUser!.uid;
//     DocumentSnapshot userDoc =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();

//     if (userDoc.exists) {
//       setState(() {
//         _profilePictureURL = userDoc['profilePicture'] ?? '';
//       });
//     }
//   }

//   Future<String> getUserRole(String email) async {
//     try {
//       // Query the 'members' collection based on the email
//       QuerySnapshot<Map<String, dynamic>> querySnapshot =
//           await FirebaseFirestore.instance
//               .collection('members')
//               .where('email', isEqualTo: email)
//               .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         // Assuming there is only one document for each email
//         Map<String, dynamic> userData = querySnapshot.docs.first.data();
//         return userData['role'] ?? 'admin';
//       } else {
//         return 'user'; // Default to 'user' role if the document does not exist
//       }
//     } catch (e) {
//       print('Error getting user role: $e');
//       return 'user'; // Handle the error gracefully, default to 'user' role
//     }
//   }

//   // Adjust the height as needed
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       // elevation: 0.0,
//       backgroundColor: widget.isDarkMode ? Colors.black87 : Colors.white,
//       automaticallyImplyLeading: false, // Hide default back button
//       flexibleSpace: ClipPath(
//         clipper: CurveClipper(),
//         child: Container(
//           color: widget.isDarkMode ? Colors.amber : Colors.amberAccent,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Positioned(
//                 left: 8.0,
//                 child: IconButton(
//                   color: widget.isDarkMode ? Colors.white : Colors.black,
//                   icon: widget.isDarkMode
//                       ? const Icon(Icons.light_mode)
//                       : const Icon(Icons.dark_mode),
//                   onPressed: widget.onDarkModeToggle,
//                 ),
//               ),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () async {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             ProfilePage(isDarkMode: widget.isDarkMode),
//                       ),
//                     );
//                     // After returning from ProfilePage, reload user data
//                     await _loadUserData();
//                     setState(() {});
//                   },
//                   child: Align(
//                     alignment: Alignment.center,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.black,
//                         border: Border.all(
//                           color:
//                               widget.isDarkMode ? Colors.white : Colors.black,
//                           width: 2.0, // Set the width of the border
//                         ),
//                       ),
//                       child: CircleAvatar(
//                         backgroundImage: _profilePictureURL.isNotEmpty
//                             ? (_profilePictureURL.startsWith('http')
//                                 ? NetworkImage(_profilePictureURL)
//                                 : FileImage(File(_profilePictureURL))
//                                     as ImageProvider<Object>?)
//                             : AssetImage(
//                                 widget.isDarkMode
//                                     ? 'assets/logo1.jpg'
//                                     : 'assets/logo.jpg',
//                               ),
//                         radius: 50, // Adjust the radius as needed
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 right: 8.0,
//                 child: IconButton(
//                   color: widget.isDarkMode ? Colors.white : Colors.black,
//                   icon: const Icon(Icons.menu),
//                   onPressed: () {
//                     // Show menu when button is pressed
//                     showMenu(
//                       context: context,
//                       position: const RelativeRect.fromLTRB(
//                           100, 100, 0, 0), // Adjust the position as needed
//                       items: [
//                         PopupMenuItem(
//                           value: 'adminPanel',
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.admin_panel_settings,
//                                 color: widget.isDarkMode
//                                     ? Colors.white
//                                     : Colors.black,
//                               ),
//                               const SizedBox(
//                                   width: 8), // Adjust spacing as needed
//                               Text(
//                                 'Admin Panel',
//                                 style: TextStyle(
//                                   color: widget.isDarkMode
//                                       ? Colors.white
//                                       : Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         PopupMenuItem(
//                           value: 'about',
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.info,
//                                 color: widget.isDarkMode
//                                     ? Colors.white
//                                     : Colors.black,
//                               ),
//                               const SizedBox(
//                                   width: 8), // Adjust spacing as needed
//                               Text(
//                                 'About',
//                                 style: TextStyle(
//                                   color: widget.isDarkMode
//                                       ? Colors.white
//                                       : Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         PopupMenuItem(
//                           value: 'logout',
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.logout,
//                                 color: widget.isDarkMode
//                                     ? Colors.white
//                                     : Colors.black,
//                               ),
//                               const SizedBox(
//                                   width: 8), // Adjust spacing as needed
//                               Text(
//                                 'Log Out',
//                                 style: TextStyle(
//                                   color: widget.isDarkMode
//                                       ? Colors.white
//                                       : Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                       color: widget.isDarkMode
//                           ? Colors.amber
//                           : Colors
//                               .amberAccent, // Set the background color of the menu
//                     ).then(
//                       (value) async {
//                         if (value == 'adminPanel') {
//                           FirebaseAuth auth = FirebaseAuth.instance;
//                           User? user = auth.currentUser;

//                           if (user != null) {
//                             // User is signed in, check if the user has admin role in Firestore
//                             FirebaseFirestore firestore =
//                                 FirebaseFirestore.instance;

//                             firestore
//                                 .collection('users')
//                                 .doc(user.uid)
//                                 .get()
//                                 .then((doc) {
//                               if (doc.exists) {
//                                 // Check if the user has admin role
//                                 if (doc['role'] == 'admin' ||
//                                     doc['role'] == 'superuser') {
//                                   // User has admin role, navigate to admin panel
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (context) => AdminPanelPage(
//                                           isDarkMode: widget.isDarkMode),
//                                     ),
//                                   );
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text(
//                                           'Successfully accessed the menu item \n WELCOME TO THE ADMIN PANEL!'),
//                                       duration: Duration(seconds: 5),
//                                     ),
//                                   );
//                                 } else {
//                                   // User doesn't have admin role
//                                   // You can show an error message or redirect to a different page
//                                   print('User does not have admin role');
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text(
//                                           'You do not have permission to access the selected menu item.'),
//                                       duration: Duration(seconds: 3),
//                                     ),
//                                   );
//                                 }
//                               } else {
//                                 // Handle the case where the user document does not exist
//                                 print('User document does not exist');
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                         'Your User document does not exist.'),
//                                     duration: Duration(seconds: 3),
//                                   ),
//                                 );
//                               }
//                             });
//                           } else {
//                             // User is not signed in, handle as needed (e.g., show login screen)
//                             print('User is not signed in');
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('You\'re  not signed in.'),
//                                 duration: Duration(seconds: 3),
//                               ),
//                             );
//                           }
//                         } else if (value == 'about') {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   AboutPage(isDarkMode: widget.isDarkMode),
//                             ),
//                           );
//                         } else if (value == 'logout') {
//                           // Perform logout when the user selects the 'logout' option
//                           _handleLogout();
//                         }

// // ScaffoldMessenger.of(context).showSnackBar(
// //                                 const SnackBar(
// //                                   content: Text(
// //                                       'You do not have permission to access the selected menu item.'),
// //                                   duration: Duration(seconds: 3),
// //                                 ),
// //                               );
//                         // else if (value == 'adminPanel') {
//                         //   Navigator.of(context).push(
//                         //     MaterialPageRoute(
//                         //       builder: (context) =>
//                         //           AdminPanelPage(isDarkMode: widget.isDarkMode),
//                         //     ),
//                         //   );
//                         // }
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleLogout() async {
//     // Perform logout when the user selects the 'logout' option
//     await _auth.signOut();

//     // Navigate to the login or registration page after logout
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const LoginPage(),
//       ),
//     );
//   }
// }
