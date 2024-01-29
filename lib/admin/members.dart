import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:word/admin/edit_member.dart';

class MembersPanel extends StatefulWidget {
  final bool isDarkMode;
  const MembersPanel({super.key, required this.isDarkMode});
  @override
  _MembersPanelState createState() => _MembersPanelState();
}

class _MembersPanelState extends State<MembersPanel> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _position = '';
  String? _role = 'client'; // Set an initial value
  String _email = '';
  String _whatsapp = '';
  String _imageUrl = '';

  final ImagePicker _imagePicker = ImagePicker();

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
          'Members Panel',
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
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onSaved: (value) => _name = value!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Position (optional)',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onSaved: (value) => _position = value!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value!,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'WhatsApp',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a WhatsApp number';
                          }
                          return null;
                        },
                        onSaved: (value) => _whatsapp = value!,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final imageFile = await _pickImage();
                          if (imageFile != null) {
                            // Upload the image to Firebase Storage
                            final imageUrl = await _uploadImage(imageFile.path);
                            // Set the imageUrl to the updated URL
                            setState(() {
                              _imageUrl = imageUrl;
                            });
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            isDarkMode ? Colors.orange : Colors.black,
                          ),
                        ),
                        child: Text(
                          'Pick Image',
                          style: TextStyle(
                            color:
                                isDarkMode ? Colors.black : Colors.orangeAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _imageUrl.isNotEmpty
                            ? 'Selected Image URL: $_imageUrl'
                            : 'No picture image selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
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
                            fontSize: 20,
                            color:
                                isDarkMode ? Colors.black : Colors.orangeAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: isDarkMode ? Colors.white : Colors.black,
                indent: 30,
                endIndent: 30,
                height: 60,
              ),
              _buildMembersList(),
              Divider(
                color: isDarkMode ? Colors.white : Colors.black,
                indent: 30,
                endIndent: 30,
                height: 60,
              ),
              _buildMembersCardList(),
              const SizedBox(height: 35)
            ],
          ),
        ),
      ),
    );
  }

  Future<XFile?> _pickImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      return pickedFile;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Check if a new image is selected
        // if (_imageUrl.isNotEmpty) {
        //   // Upload the new image to Firebase Storage
        //   final imageUrl = await _uploadImage(_imageUrl);
        //   // Set the imageUrl to the updated URL
        //   setState(() {
        //     _imageUrl = imageUrl;
        //   });
        // }

        // Save member details to Firestore
        await FirebaseFirestore.instance.collection("members").add({
          'name': _name,
          'position': _position,
          'email': _email,
          'whatsapp': _whatsapp,
          'role': _role,
          'imageUrl': _imageUrl,
        });

        // Clear the form
        _formKey.currentState!.reset();

        // Show a success message or navigate back
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Member details added successfully!'),
          duration: Duration(seconds: 3),
        ));
      } catch (e) {
        // Handle errors, e.g., show an error message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error adding member details. Please try again.'),
          duration: Duration(seconds: 3),
        ));
      }
    }
  }

  Future<String> _uploadImage(String imagePath) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('members_images')
          .child(DateTime.now().toString());
      await storageRef.putFile(File(imagePath));
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Widget _buildMembersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('members').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No members found"));
        }

        List<Widget> memberCards = [];

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;

          memberCards.add(
            Card(
              color: widget.isDarkMode ? Colors.orange : Colors.orangeAccent,
              shadowColor: widget.isDarkMode ? Colors.white : Colors.black,
              child: ListTile(
                leading: CircleAvatar(
                  // backgroundImage: data['imageUrl'] != null
                  //     ? NetworkImage(data['imageUrl'])
                  //     : AssetImage(
                  //         widget.isDarkMode
                  //             ? 'assets/logo1.jpg'
                  //             : 'assets/logo.jpg',
                  //       ) as ImageProvider<Object>?,
                  backgroundImage:
                      data['imageUrl'] != null && data['imageUrl'] is String
                          ? NetworkImage(data['imageUrl'])
                          : AssetImage(
                              widget.isDarkMode
                                  ? 'assets/logo1.jpg'
                                  : 'assets/logo.jpg',
                            ) as ImageProvider<Object>?,

                  radius: 25,
                ),
                title: Text(
                  data['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  data['position'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  onSelected: (value) {
                    // Handle the selected option
                    if (value == 'delete') {
                      _showDeleteConfirmation(context, doc.id);
                    } else if (value == 'view') {
                      _showMemberDetailsDialog(data);
                    } else if (value == 'edit') {
                      _navigateToEditScreen(
                        context,
                        doc.id,
                      );
                    }
                    // Add more options as needed
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: widget.isDarkMode
                                ? Colors.orange
                                : Colors.orangeAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.orange
                                  : Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            color: widget.isDarkMode
                                ? Colors.orange
                                : Colors.orangeAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'View',
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.orange
                                  : Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: widget.isDarkMode
                                ? Colors.orange
                                : Colors.orangeAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.orange
                                  : Colors.orangeAccent,
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
        return Column(children: memberCards);
      },
    );
  }

  void _navigateToEditScreen(
    BuildContext context,
    String documentId,
  ) async {
    try {
      // Fetch data from Firestore using documentId
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(documentId)
          .get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        Map<String, dynamic> memberData =
            documentSnapshot.data() as Map<String, dynamic>;

        // Navigate to the edit screen with data and documentId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditMemberScreen(
                memberData: memberData,
                documentId: documentId,
                isDarkMode: widget.isDarkMode),
          ),
        );
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _showMemberDetailsDialog(Map<String, dynamic> memberData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              widget.isDarkMode ? Colors.orange : Colors.orangeAccent,
          title: Text(
            memberData['name'],
            style: TextStyle(
              fontSize: 30,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Position: ${memberData['position'] ?? 'N/A'}'),
              Text('Email: ${memberData['email'] ?? 'N/A'}'),
              Text('WhatsApp: ${memberData['whatsapp'] ?? 'N/A'}'),
              // Add other details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this Member?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteBook(documentId);
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteBook(String documentId) async {
    try {
      // Replace 'devotions' with your actual collection name
      await FirebaseFirestore.instance
          .collection('members')
          .doc(documentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The Member has been deleted successfully'),
          duration: Duration(seconds: 5),
        ),
      );
      print('The member has been deleted successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting Member!'),
          duration: Duration(seconds: 5),
        ),
      );
      print('Error deleting book: $e');
      // Handle the error as needed
    }
  }

  Widget _buildMembersCardList() {
    final isDarkMode = widget.isDarkMode;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('members').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No members found"));
        }

        return Container(
          color: isDarkMode ? Colors.black : Colors.white,
          height: 250,
          child: PageView.builder(
            itemCount: snapshot.data!.docs.length,
            controller: PageController(viewportFraction: 0.6),
            itemBuilder: (context, index) {
              var member = snapshot.data!.docs[index];
              var name = member['name'];
              var position = member['position'] ?? '';
              var whatsapp = member['whatsapp'] ?? '';
              var email = member['email'] ?? '';
              var imageUrl = member['imageUrl'] ?? 'assets/default_image.png';

              return Card(
                color: isDarkMode ? Colors.white24 : Colors.amber,
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular profile image
                    ClipOval(
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.isDarkMode
                                  ? 'assets/logo1.jpg'
                                  : 'assets/logo.jpg',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                    ),

                    const SizedBox(height: 8),
                    // Position and Name with color
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.amber : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey : Colors.white70,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // gmail
                        GestureDetector(
                          onTap: () {
                            _launchURL('mailto:$email');
                          },
                          child: Image.asset('assets/gmail.png',
                              height: 40, width: 40),
                        ),
                        // cell
                        GestureDetector(
                          onTap: () {
                            _launchURL('tel:+26$whatsapp');
                          },
                          child: Image.asset('assets/cell.png',
                              height: 40,
                              width:
                                  40), // Replace with the actual path to your phone icon image
                        ),
                        // whatsapp
                        // GestureDetector(
                        //   onTap: () {
                        //     _launchURL('https://wa.me/message/EGZ5XH36UJHTK1');
                        //   },
                        //   child: Image.asset('assets/whatsapp.png',
                        //       height: 40, width: 40),
                        // ),
                        // Add more social media icons as needed
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
