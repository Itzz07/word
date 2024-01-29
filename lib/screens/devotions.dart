import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:word/widgets/floating_button.dart';

class DevotionsPage extends StatefulWidget {
  final bool isDarkMode;
  final void Function() toggleDarkMode;

  const DevotionsPage({
    Key? key,
    required this.isDarkMode,
    required this.toggleDarkMode,
  }) : super(key: key);

  @override
  State<DevotionsPage> createState() => _DevotionsPageState();
}

class _DevotionsPageState extends State<DevotionsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      body: _buildDevotionList(),
      floatingActionButton:
          ScrollToTopButton(scrollController: _scrollController),
    );
  }

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
          controller: _scrollController, // Add this line
          itemCount: (snapshot.data as QuerySnapshot).docs.length,
          itemBuilder: (context, index) {
            var devotion = (snapshot.data as QuerySnapshot).docs[index];
            var briefText = devotion['briefText'];
            var paragraph = devotion['paragraph'];
            var scripture = devotion['scripture'];
            var timestamp = devotion['timestamp'];

            return Card(
              elevation: 5.0,
              color: isDarkMode ? Colors.amber : Colors.amberAccent,
              shadowColor: isDarkMode ? Colors.white : Colors.black,
              // margin: const EdgeInsets.all(8),
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
              ),
            );
          },
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
}
