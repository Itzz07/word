import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word/model/notification_service.dart';

class EditVideoPage extends StatefulWidget {
  final String videoId;
  final bool isDarkMode;

  EditVideoPage({required this.videoId, required this.isDarkMode});

  @override
  _EditVideoPageState createState() => _EditVideoPageState();
}

class _EditVideoPageState extends State<EditVideoPage> {
  final TextEditingController headingController = TextEditingController();
  final TextEditingController linksController = TextEditingController();
  final NotificationService notificationService = NotificationService();
  String originalHeading = '';
  String originalLinks = '';

  @override
  void initState() {
    super.initState();
    print('widget.videoId: ${widget.videoId}');
    if (widget.videoId != null && widget.videoId.isNotEmpty) {
      _loadVideoData();
    }
  }

  // Future<void> _loadVideoData() async {
  //   try {
  //     // Fetch video data from Firestore based on videoId
  //     DocumentSnapshot videoSnapshot = await FirebaseFirestore.instance
  //         .collection('videos')
  //         .doc(widget.videoId)
  //         .get();

  //     // Set the data to the controllers
  //     Map<String, dynamic> data = videoSnapshot.data() as Map<String, dynamic>;
  //     originalHeading = data['heading'];
  //     originalLinks = data['links'];
  //     headingController.text = originalHeading;
  //     linksController.text = originalLinks;
  //   } catch (e) {
  //     // Handle error
  //     print('Error loading video data: $e');
  //   }
  // }

  Future<void> _loadVideoData() async {
    if (widget.videoId.isEmpty) {
      // Handle the case where videoId is empty
      print('Error loading video data: videoId is empty');
      return;
    }

    try {
      // Fetch video data from Firestore based on videoId
      DocumentSnapshot videoSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.videoId)
          .get();

      // Set the data to the controllers
      Map<String, dynamic> data = videoSnapshot.data() as Map<String, dynamic>;
      originalHeading = data['heading'];
      originalLinks = data['links'];
      headingController.text = originalHeading;
      linksController.text = originalLinks;
    } catch (e) {
      // Handle error
      print('Error loading video data: $e');
    }
  }

  Future<void> _updateVideo() async {
    try {
      // Get the updated values or retain the original values if empty
      String updatedHeading = headingController.text.isEmpty
          ? originalHeading
          : headingController.text;
      String updatedLinks =
          linksController.text.isEmpty ? originalLinks : linksController.text;

      // Update video details in Firestore
      await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.videoId)
          .update({
        'heading': updatedHeading,
        'links': updatedLinks,
      });

      // Show local notification
      notificationService.showNotification(
        'Video Updated',
        'Video details have been updated.',
      );

      // Show a SnackBar to indicate successful update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video updated successfully!'),
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      // Handle errors if the video details couldn't be updated in Firestore
      print('Error updating video: $e');

      // Show a SnackBar to indicate an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating video. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.teal : Colors.tealAccent,
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
          'Edit Content',
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
                      controller: headingController,
                      decoration: InputDecoration(
                        labelText: 'Heading',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    TextField(
                      controller: linksController,
                      decoration: InputDecoration(
                        labelText: 'Link',
                        labelStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _updateVideo,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          isDarkMode ? Colors.teal : Colors.black,
                        ),
                      ),
                      child: Text(
                        'Update Video',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.black : Colors.tealAccent,
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
