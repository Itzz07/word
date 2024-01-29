import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:word/admin/edit_video.dart';
import 'package:word/model/notification_service.dart';
import 'package:word/widgets/floating_button.dart';

class VideosPanel extends StatefulWidget {
  final bool isDarkMode;
  const VideosPanel({super.key, required this.isDarkMode});
  @override
  _VideosPanelState createState() => _VideosPanelState();
}

class _VideosPanelState extends State<VideosPanel> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController headingController = TextEditingController();
  final TextEditingController linksController = TextEditingController();
  final NotificationService notificationService = NotificationService();
  Future<void> _showNotification(String title, String message) async {
    await notificationService.showNotification(title, message);
  }

  Future<void> _addVideo() async {
    String heading =
        headingController.text; // Store the heading before clearing

    try {
      // Add video details to Firestore
      await FirebaseFirestore.instance.collection('videos').add({
        'heading': heading,
        'links': linksController.text,
      });

      // Show local notification
      _showNotification('New Content Uploaded', '$heading has been uploaded.');

      // Clear text controllers after adding video
      headingController.clear();
      linksController.clear();

      // Show a SnackBar to indicate successful submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content uploaded successfully!'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
        ),
      );
    } catch (e) {
      // Handle errors if the video details couldn't be added to Firestore
      print('Error uploading content: $e');

      // Show a SnackBar to indicate an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading content. Please try again.'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
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
          'Content Panel',
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
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              controller:
                  _scrollController, // Assign the ScrollController to the SingleChildScrollView
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Add video form
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
                          onPressed: _addVideo,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              isDarkMode ? Colors.teal : Colors.black,
                            ),
                          ),
                          child: Text(
                            'Save Video',
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  isDarkMode ? Colors.black : Colors.tealAccent,
                            ),
                          ),
                        ),
                        Divider(
                          color: isDarkMode ? Colors.white : Colors.black,
                          indent: 30,
                          endIndent: 30,
                          height: 60,
                        ),
                        // Show videos from Firestore
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('videos')
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            return Column(
                              key: Key('videoList'),
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                return VideoCard(
                                  video: Video(
                                    videoId: document.id,
                                    heading: data['heading'],
                                    links: data['links'],
                                    isDarkMode: isDarkMode,
                                  ),
                                  isDarkMode: isDarkMode,
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add ScrollToTopButton aligned to the bottom-right corner
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ScrollToTopButton(scrollController: _scrollController),
            ),
          ),
        ],
      ),
    );
  }
}

class Video {
  final String videoId;
  final String heading;
  final String links;
  final bool isDarkMode;

  Video({
    required this.videoId,
    required this.isDarkMode,
    required this.heading,
    required this.links,
  });
}

class VideoCard extends StatelessWidget {
  final Video video;
  final bool isDarkMode;

  const VideoCard({required this.video, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showOptions(context);
      },
      child: Card(
        elevation: 3.0,
        color: isDarkMode ? Colors.teal : Colors.tealAccent,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                video.heading,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                'Link: ${video.links}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: isDarkMode ? Colors.teal : Colors.tealAccent,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.edit,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text('Edit',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  )),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => EditVideoPage(
                      isDarkMode: isDarkMode,
                      videoId:
                          video.videoId, // Use videoId from the video object
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text('Delete',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  )),
              onTap: () {
                _showDeleteConfirmation(context);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.visibility,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              title: Text(
                'View',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                _showViewConfirmation(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.teal : Colors.tealAccent,
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this video?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteVideo(); // Delete the video
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Delete',
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

  _deleteVideo() async {
    // Implement the logic to delete the video from Firestore
    // You can use the document ID or any unique identifier to delete the video
    try {
      await FirebaseFirestore.instance
          .collection('videos')
          .where('heading', isEqualTo: video.heading)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // Show a SnackBar to indicate successful deletion
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Video deleted successfully!'),
      //     duration: Duration(seconds: 3), // Adjust the duration as needed
      //   ),
      // );
    } catch (e) {
      // Handle errors if the video couldn't be deleted from Firestore
      print('Error deleting video: $e');

      // Show a SnackBar to indicate an error
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Error deleting video. Please try again.'),
      //     duration: Duration(seconds: 3), // Adjust the duration as needed
      //   ),
      // );
    }
  }

  _showViewConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.teal : Colors.tealAccent,
          title: Text('Confirmation'),
          content: Text('Do you want to open this link?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                _launchLink(); // Open the link
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Open Link',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _launchLink() async {
    // Open the link
    if (await canLaunch(video.links)) {
      await launch(video.links);
    } else {
      // Handle error
      print('Could not launch ${video.links}');
    }
  }
}
