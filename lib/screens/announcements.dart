import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:word/widgets/floating_button.dart';

class AnnouncementsPage extends StatefulWidget {
  final bool isDarkMode;
  final void Function() toggleDarkMode;

  const AnnouncementsPage({
    Key? key,
    required this.isDarkMode,
    required this.toggleDarkMode,
  }) : super(key: key);

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      body: _buildAnnouncementList(isDarkMode),
      floatingActionButton:
          ScrollToTopButton(scrollController: _scrollController),
    );
  }

  Widget _buildAnnouncementList(bool isDarkMode) {
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
          controller: _scrollController,
          itemCount: (snapshot.data as QuerySnapshot).docs.length,
          itemBuilder: (context, index) {
            var announcement = (snapshot.data as QuerySnapshot).docs[index];
            var heading = announcement['heading'];
            var paragraph = announcement['paragraph'];
            var timestamp = announcement['timestamp'];

            return Card(
              elevation: 3.0,
              shadowColor: isDarkMode ? Colors.lime : Colors.limeAccent,
              color: isDarkMode ? Colors.black54 : Colors.white60,
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    heading,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timestamp != null ? _formatTimestamp(timestamp) : '',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(
                  Icons.notifications,
                  color: isDarkMode ? Colors.amber : Colors.amberAccent,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paragraph,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.white : Colors.black,
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

  String _formatTimestamp(Timestamp timestamp) {
    if (timestamp == null) {
      return 'N/A';
    }
    DateTime dateTime = timestamp.toDate();
    String formattedDateTime = DateFormat.yMMMMd().add_jm().format(dateTime);
    return formattedDateTime;
  }
}
