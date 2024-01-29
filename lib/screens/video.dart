import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:word/widgets/floating_button.dart';

class VideoPage extends StatefulWidget {
  final bool isDarkMode;
  final void Function() toggleDarkMode;

  const VideoPage({
    super.key,
    required this.isDarkMode,
    required this.toggleDarkMode,
  });

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      body: _buildVideoList(),
      floatingActionButton:
          ScrollToTopButton(scrollController: _scrollController),
    );
  }

  Widget _buildVideoList() {
    final isDarkMode = widget.isDarkMode;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('videos').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return VideoCard(
              video: Video(
                heading: data['heading'],
                links: data['links'],
                isDarkMode: isDarkMode,
              ),
              isDarkMode: isDarkMode,
            );
          }).toList(),
        );
      },
    );
  }
}

class Video {
  final String heading;
  final String links;
  final bool isDarkMode;

  Video({
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
        _showConfirmationDialog(context);
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/video.png'), // Replace with your image path
            fit: BoxFit.fill,
          ),
        ),
        child: Card(
          elevation: 1.0,
          shadowColor: isDarkMode ? Colors.grey : Colors.white,
          color: Colors.transparent, // Set card color to transparent
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  video.heading,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: isDarkMode ? Colors.yellow : Colors.yellowAccent,
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
      ),
    );
  }

  _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: isDarkMode ? Colors.lime : Colors.limeAccent,
          backgroundColor: isDarkMode ? Colors.black54 : Colors.white60,
          title: Text(
            'Confirmation',
            style: TextStyle(
              color: isDarkMode ? Colors.amber : Colors.black,
            ),
          ),
          content: Text(
            'Do you want to open this link?',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.indigo : Colors.indigoAccent,
                ),
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
                  color: isDarkMode ? Colors.white : Colors.black,
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
