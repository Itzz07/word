import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:word/model/notification_service.dart';
import 'package:word/screens/books.dart';

class BookPanel extends StatefulWidget {
  final bool isDarkMode;

  const BookPanel({super.key, required this.isDarkMode});

  @override
  _BookPanelState createState() => _BookPanelState();
}

class _BookPanelState extends State<BookPanel> {
  showNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // const IOSInitializationSettings initializationSettingsIOS =
    //     IOSInitializationSettings(
    //   requestSoundPermission: false,
    //   requestBadgePermission: false,
    //   requestAlertPermission: false,
    // );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high channel',
      'Very important notification!!',
      description: 'the first notification',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin.show(
      1,
      'my first notification',
      'a very long message for the user of app',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          showWhen: false,
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String title = '';
  String author = '';
  File? selectedFile;
  File? coverImageFile;

  final NotificationService notificationService = NotificationService();

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

  Future<void> _uploadData() async {
    if (selectedFile == null || title.isEmpty || author.isEmpty) {
      // Show an error message or handle validation
      return;
    }

    try {
      // Upload cover image to Firebase Storage
      Reference coverStorageReference = FirebaseStorage.instance
          .ref()
          .child('covers/${DateTime.now().millisecondsSinceEpoch}.png');

      if (coverImageFile != null) {
        await coverStorageReference.putFile(coverImageFile!);
      } else {
        // If no cover image is selected, you can choose to handle it differently
        print('No cover image selected.');
      }

      // Get download URL for the uploaded cover image
      String coverDownloadURL = await coverStorageReference.getDownloadURL();

      // Upload PDF file to Firebase Storage
      Reference pdfStorageReference = FirebaseStorage.instance
          .ref()
          .child('pdfs/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = pdfStorageReference.putFile(selectedFile!);
      await uploadTask.whenComplete(() => null);

      // Get download URL for PDF
      String pdfDownloadURL = await pdfStorageReference.getDownloadURL();

      // Store data in Firestore with timestamp and PDF download URL
      DocumentReference documentReference =
          await FirebaseFirestore.instance.collection('books').add({
        'title': title,
        'author': author,
        'pdf_url': pdfDownloadURL,
        'timestamp': FieldValue.serverTimestamp(),
        'cover_url': coverDownloadURL,
      });

      /// Show local notification
      _showNotification('New Book Uploaded',
          'Book Titled $title By $author has been uploaded.');
      // Reset form
      setState(() {
        selectedFile = null;
        coverImageFile = null;
        title = '';
        author = '';
      });

      // Show success notice using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload successful!'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error: $e');
      // Handle error
      // Show error notice using SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading data. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Future<void> _sendNotification(
  //   String userId,
  //   String bookId,
  //   String bookTitle,
  //   String bookAuthor,
  // ) async {
  //   try {
  //     FirebaseMessaging messaging = FirebaseMessaging.instance;
  //     await messaging
  //         .subscribeToTopic('book_updates'); // Subscribe to a general topic

  //     // Subscribe to user-specific topic and all books topic
  //     await messaging.subscribeToTopic(userId);
  //     await messaging.subscribeToTopic(bookId);
  //     await messaging.subscribeToTopic('all_books');

  //     // Customize the notification payload
  //     RemoteNotification? notification = RemoteNotification(
  //       title: 'New Book Uploaded',
  //       body: '$bookTitle by $bookAuthor is now available!',
  //     );

  //     // Define the background handler
  //     FirebaseMessaging.onBackgroundMessage((message) async {
  //       // Handle the background message here
  //       print('Handling background message: $message');
  //     });

  //     // Send the notification to the subscribed topic
  //     await FirebaseMessaging.instance.subscribeToTopic(userId);
  //     await FirebaseMessaging.instance.(
  //       userId,
  //       RemoteMessage(
  //         data: {},
  //         notification: notification,
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error sending notification: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.purple : Colors.purpleAccent,
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
          'Books Panel',
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
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onChanged: (value) {
                        setState(() {
                          title = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Author',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onChanged: (value) {
                        setState(() {
                          author = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('show notification'),
                      onPressed: () async {
                        showNotification();
                      },
                    ),
                    // pick pdf
                    ElevatedButton(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );

                        if (result != null) {
                          setState(() {
                            selectedFile = File(result.files.single.path!);
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          isDarkMode ? Colors.purple : Colors.black,
                        ),
                      ),
                      child: Text(
                        'Pick PDF File',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.black : Colors.purpleAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedFile != null
                          ? 'File selected: ${selectedFile!.path.split('/').last}'
                          : 'No file selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'jpeg', 'png'],
                        );

                        if (result != null) {
                          setState(() {
                            coverImageFile = File(result.files.single.path!);
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          isDarkMode ? Colors.purple : Colors.black,
                        ),
                      ),
                      // pick image
                      child: Text(
                        'Pick Cover Image',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.black : Colors.purpleAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      coverImageFile != null
                          ? 'Cover Image selected: ${coverImageFile!.path.split('/').last}'
                          : 'No cover image selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _uploadData,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          isDarkMode ? Colors.purple : Colors.black,
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              isDarkMode ? Colors.black : Colors.purpleAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: isDarkMode ? Colors.white : Colors.black,
                indent: 30,
                endIndent: 30,
              ),
              SizedBox(
                height: 300,
                child: _buildBookList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookList() {
    final isDarkMode = widget.isDarkMode;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('books')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        return ListView(
          shrinkWrap: true,
          children: snapshot.data!.docs.map((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return ListTile(
              leading: Image.network(
                data['cover_url'] ?? '',
                width: 55,
                height: 100,
                fit: BoxFit.fill,
              ),
              title: Text(
                data['title'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isDarkMode ? Colors.purple : Colors.purpleAccent,
                ),
              ),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Author: ${data['author'] ?? ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: isDarkMode ? Colors.grey : Colors.black,
                      ),
                    ),
                    Text(
                      'Posted on: ${_formatTimestamp(data['timestamp'])}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey : Colors.grey[800],
                      ),
                    ),
                  ]),
              trailing: GestureDetector(
                onTap: () {
                  _showDeleteConfirmation(context, document.id);
                },
                child: Icon(
                  Icons.delete,
                  color: isDarkMode ? Colors.purple : Colors.purpleAccent,
                ),
              ),
            );
          }).toList(),
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
          content: const Text("Are you sure you want to delete this book?"),
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
          .collection('books')
          .doc(documentId)
          .delete();
      print('The book has been deleted successfully');
    } catch (e) {
      print('Error deleting book: $e');
      // Handle the error as needed
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp != null) {
      DateTime dateTime = timestamp.toDate();
      String formattedDateTime = DateFormat.yMMMMd().add_jm().format(dateTime);
      return formattedDateTime;
    } else {
      return '';
    }
  }
}
