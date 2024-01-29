import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:word/model/notification_service.dart';

class AnnouncementPanel extends StatefulWidget {
  final bool isDarkMode;

  const AnnouncementPanel({super.key, required this.isDarkMode});

  @override
  _AnnouncementPanelState createState() => _AnnouncementPanelState();
}

class _AnnouncementPanelState extends State<AnnouncementPanel> {
  final _formKey = GlobalKey<FormState>();
  late String _heading;
  late String _paragraph;
  final NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.green : Colors.greenAccent,
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
          'Announcement Panel',
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
                  color: isDarkMode ? Colors.green : Colors.greenAccent,
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
                              return 'Please enter a heading';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _heading = value!;
                          },
                        ),
                        TextFormField(
                          autocorrect: true,
                          decoration: const InputDecoration(
                            labelText: 'Announcement',
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
                              color: isDarkMode ? Colors.green : Colors.white,
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
                height: 40,
              ),
              SizedBox(
                height: 300, // Set your desired height here
                child: _buildAnnouncementList(),
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

      // Save the form data to Firebase (Replace 'announcements' with your actual collection name)
      FirebaseFirestore.instance.collection('announcements').add({
        'heading': _heading,
        'paragraph': _paragraph,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the form after submission
      _formKey.currentState!.reset();

      // Show a SnackBar to indicate successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement submitted successfully!'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );

      /// Show local notification
      _showNotification('Announcement', _heading);
    } else {
      // Show a SnackBar to indicate validation error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form.'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    }
  }

  Widget _buildAnnouncementList() {
    final isDarkMode = widget.isDarkMode;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('announcements')
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
          return const Center(child: Text('No announcements available.'));
        }

        return ListView.builder(
          itemCount: (snapshot.data as QuerySnapshot).docs.length,
          itemBuilder: (context, index) {
            var announcement = (snapshot.data as QuerySnapshot).docs[index];
            var heading = announcement['heading'];
            var paragraph = announcement['paragraph'];
            var timestamp = announcement['timestamp'];

            return Card(
              color: isDarkMode ? Colors.green : Colors.greenAccent,
              shadowColor: isDarkMode ? Colors.white : Colors.black,
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    heading,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
                subtitle: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timestamp != null ? _formatTimestamp(timestamp) : '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    _showDeleteAnnouncementConfirmation(
                        context, announcement.id);
                  },
                  child: Icon(
                    Icons.delete,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteAnnouncementConfirmation(
      BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Announcement"),
          content:
              const Text("Are you sure you want to delete this announcement?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteAnnouncement(documentId);
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

  void _deleteAnnouncement(String documentId) async {
    try {
      // Replace 'announcements' with your actual collection name
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(documentId)
          .delete();
      print('Announcement deleted successfully');
    } catch (e) {
      print('Error deleting announcement: $e');
      // Handle the error as needed
    }
  }
}
