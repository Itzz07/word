import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserPage extends StatefulWidget {
  final String userId;
  final bool isDarkMode;

  EditUserPage({required this.userId, required this.isDarkMode});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final TextEditingController nameController = TextEditingController();
  String originalName = '';
  String selectedRole = 'client';
  List<String> roles = ['admin', 'client'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch user data from Firestore based on userId
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      // Set the data to the controllers
      Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
      originalName = data['name'];
      selectedRole = data['role'] ?? 'client';
      nameController.text = originalName;
    } catch (e) {
      // Handle error
      print('Error loading user data: $e');
    }
  }

  Future<void> _updateUser() async {
    try {
      // Get the updated values or retain the original values if empty
      String updatedName =
          nameController.text.isEmpty ? originalName : nameController.text;

      // Update user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': updatedName,
        'role': selectedRole,
      });

      // Show a SnackBar to indicate successful update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully!'),
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Handle errors if the user details couldn't be updated in Firestore
      print('Error updating user: $e');

      // Show a SnackBar to indicate an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating user. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final TextStyle labelStyle = TextStyle(
      color: isDarkMode ? Colors.white : Colors.black,
    );
    final TextStyle textFieldStyle = TextStyle(
      color: isDarkMode ? Colors.white : Colors.black,
    );

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.indigo : Colors.indigoAccent,
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
          'Edit User',
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: labelStyle,
                      ),
                      style: textFieldStyle,
                    ),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      dropdownColor:
                          isDarkMode ? Colors.indigo : Colors.indigoAccent,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        labelStyle: labelStyle,
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      value: selectedRole,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRole = newValue!;
                        });
                      },
                      items: roles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(
                            role,
                            style: textFieldStyle,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _updateUser,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          isDarkMode ? Colors.indigo : Colors.black,
                        ),
                      ),
                      child: Text(
                        'Update User',
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              isDarkMode ? Colors.black : Colors.indigoAccent,
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
    );
  }
}
