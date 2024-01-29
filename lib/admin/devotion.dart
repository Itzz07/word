import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:word/model/notification_service.dart';

class DevotionPanel extends StatefulWidget {
  final bool isDarkMode;

  const DevotionPanel({super.key, required this.isDarkMode});
  @override
  _DevotionPanelState createState() => _DevotionPanelState();
}

class _DevotionPanelState extends State<DevotionPanel> {
  final _formKey = GlobalKey<FormState>();
  late String _briefText;
  late String _paragraph;
  late String _scripture;
  final NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.blue : Colors.blueAccent,
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
          'Devotion Panel',
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
                child: Container(
                  color: isDarkMode ? Colors.blue : Colors.blueAccent,
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          autocorrect: true,
                          decoration: const InputDecoration(
                            labelText: 'Heading',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a brief text';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _briefText = value!;
                          },
                        ),
                        TextFormField(
                          autocorrect: true,
                          decoration: const InputDecoration(
                            labelText: 'Paragraph',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a paragraph';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _paragraph = value!;
                          },
                        ),
                        TextFormField(
                          autocorrect: true,
                          decoration: const InputDecoration(
                            labelText: 'Quoted Scripture',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          onSaved: (value) {
                            _scripture = value!;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _submitForm();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.black,
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? Colors.blue : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                color: isDarkMode ? Colors.white : Colors.black,
                indent: 30,
                endIndent: 30,
                height: 35,
              ),
              SizedBox(
                height: 300, // Set your desired height here
                child: _buildDevotionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeNotification();
  }

  Future<void> _initializeNotification() async {
    await notificationService.initializeNotifications();
  }

  Future<void> _showNotification(String title, String message) async {
    await notificationService.showNotification(title, message);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save the form data to Firebase (Replace 'devotions' with your actual collection name)
      FirebaseFirestore.instance.collection('devotions').add({
        'briefText': _briefText,
        'paragraph': _paragraph,
        'scripture': _scripture,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the form after submission
      _formKey.currentState!.reset();

      // Show a SnackBar to indicate successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devotion submitted successfully!'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
        ),
      );

      // Show local notification
      _showNotification('Devotion', _briefText);
    } else {
      // Show a SnackBar to indicate validation error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form.'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
        ),
      );
    }
  }

  // Widget _buildDevotionList() {
  //   final isDarkMode = widget.isDarkMode;

  //   return StreamBuilder(
  //     stream: FirebaseFirestore.instance
  //         .collection('devotions')
  //         .orderBy('timestamp', descending: true)
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const CircularProgressIndicator();
  //       }

  //       if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       }

  //       if (!snapshot.hasData ||
  //           (snapshot.data as QuerySnapshot).docs.isEmpty) {
  //         return const Center(child: Text('No devotions available.'));
  //       }

  //       return ListView.builder(
  //         itemCount: (snapshot.data as QuerySnapshot).docs.length,
  //         itemBuilder: (context, index) {
  //           var devotion = (snapshot.data as QuerySnapshot).docs[index];
  //           var briefText = devotion['briefText'];
  //           var paragraph = devotion['paragraph'];
  //           var scripture = devotion['scripture'];
  //           var timestamp = devotion['timestamp'];

  //           return Card(
  //             color: isDarkMode ? Colors.blue : Colors.blueAccent,
  //             shadowColor: isDarkMode ? Colors.white : Colors.black,
  //             margin: const EdgeInsets.all(8),
  //             child: ListTile(
  //               title: Text(
  //                 briefText,
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               subtitle: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     paragraph,
  //                     style: const TextStyle(
  //                       fontSize: 18,
  //                       color: Colors.black,
  //                     ),
  //                   ),
  //                   Text(
  //                     '$scripture',
  //                     style: const TextStyle(
  //                       fontSize: 15,
  //                       color: Colors.black54,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     timestamp != null ? _formatTimestamp(timestamp) : '',
  //                     // _formatTimestamp(timestamp),
  //                     style: const TextStyle(
  //                       fontSize: 13,
  //                       fontStyle: FontStyle.italic,
  //                       color: Colors.black,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               trailing: GestureDetector(
  //                 onTap: () {
  //                   _showDeleteConfirmation(context, devotion.id);
  //                 },
  //                 child: Icon(
  //                   Icons.delete,
  //                   color: isDarkMode ? Colors.black : Colors.white,
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  Widget _buildDevotionList() {
    final isDarkMode = widget.isDarkMode;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('devotions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData ||
            (snapshot.data as QuerySnapshot).docs.isEmpty) {
          return const Center(child: Text('No devotions available.'));
        }

        return ListView.builder(
          itemCount: (snapshot.data as QuerySnapshot).docs.length,
          itemBuilder: (context, index) {
            var devotion = (snapshot.data as QuerySnapshot).docs[index];
            var briefText = devotion['briefText'];
            var paragraph = devotion['paragraph'];
            var scripture = devotion['scripture'];
            var timestamp = devotion['timestamp'];

            return Card(
              color: isDarkMode ? Colors.blue : Colors.blueAccent,
              shadowColor: isDarkMode ? Colors.white : Colors.black,
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    briefText,
                    maxLines: 5, // Show only 5 lines initially
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(
                        '$scripture',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(
                        timestamp != null ? _formatTimestamp(timestamp) : '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: GestureDetector(
                  onTap: () {
                    _showDeleteConfirmation(context, devotion.id);
                  },
                  child: Icon(
                    Icons.delete,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paragraph,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Devotion"),
          content: const Text("Are you sure you want to delete this devotion?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteDevotion(documentId);
                Navigator.of(context).pop();
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

  String _formatTimestamp(Timestamp timestamp) {
    if (timestamp == null) {
      return 'N/A'; // Or any default value or an empty string
    }
    DateTime dateTime = timestamp.toDate();
    String formattedDateTime = DateFormat.yMMMMd().add_jm().format(dateTime);
    return formattedDateTime;
  }

  void _deleteDevotion(String documentId) async {
    try {
      // Replace 'devotions' with your actual collection name
      await FirebaseFirestore.instance
          .collection('devotions')
          .doc(documentId)
          .delete();
      print('Devotion deleted successfully');
    } catch (e) {
      print('Error deleting devotion: $e');
      // Handle the error as needed
    }
  }
}
