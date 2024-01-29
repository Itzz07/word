import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:word/screens/pdfviewer.dart';
import 'package:word/widgets/floating_button.dart';

class BooksPage extends StatefulWidget {
  final Color backgroundColord;
  final bool isDarkMode;
  final void Function() toggleDarkMode;

  const BooksPage({
    Key? key,
    required this.backgroundColord,
    required this.isDarkMode,
    required this.toggleDarkMode,
  }) : super(key: key);

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  bool isPdfViewerOpen = false;
  final ScrollController _scrollController = ScrollController();

  Future<String> _viewPdf(String pdfUrl, String pdfFileName) async {
    // Check and request storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    // Get the application directory
    Directory appDir = await getApplicationDocumentsDirectory();

    // Ensure the file name has a ".pdf" extension
    if (!pdfFileName.toLowerCase().endsWith('.pdf')) {
      pdfFileName += '.pdf';
    }

    // Create a file with a unique name in the app directory
    File pdfFile = File('${appDir.path}/$pdfFileName');

    // Download the PDF file from Firebase Storage using Dio
    try {
      final dio = Dio();
      await dio.download(
        pdfUrl,
        pdfFile.path,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      return pdfFile.path; // Return the path of the downloaded PDF
    } catch (e) {
      print('Error downloading PDF: $e');
      // Show an error message if the download fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download PDF'),
        ),
      );
      return ''; // Return an empty string to indicate failure
    }
  }

  Future<void> _downloadPdf(String pdfUrl, String pdfFileName) async {
    // Check and request storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    // Get the user-selected directory
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    // Ensure the file name has a ".pdf" extension
    if (!pdfFileName.toLowerCase().endsWith('.pdf')) {
      pdfFileName += '.pdf';
    }

    // Create a file with a unique name in the selected directory
    File pdfFile = File('$directoryPath/$pdfFileName');

    // Download the PDF file from Firebase Storage using Dio
    try {
      // Show a loading indicator while waiting for the authentication result
      showDialog(
        context: context,
        barrierDismissible:
            false, // Prevent the user from dismissing the dialog
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      // downloading
      final dio = Dio();
      await dio.download(
        pdfUrl,
        pdfFile.path,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      print('Storage Permission Status: $status');
      print('PDF File Path: ${pdfFile.path}');
      // Close the loading dialog
      Navigator.pop(context);
      // Show a message indicating that the download is complete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF Downloaded and Saved'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      print('Error downloading PDF: $e');
      // Close the loading dialog in case of an error
      Navigator.pop(context);
      // Show an error message if the download fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download PDF'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: widget.backgroundColord,
      body: Stack(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('books')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator(); // Loading indicator
              }

              return ListView(
                controller: _scrollController,
                shrinkWrap: true,
                children: snapshot.data!.docs.map((document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: Image.network(
                      // Assuming you store the cover image URL in 'cover_url' field
                      data['cover_url'] ?? '',
                      width: 55,
                      height: 100,
                      fit: BoxFit.fill,
                    ),
                    title: Text(
                      data['title'] ?? '',
                      style: TextStyle(
                        color: isDarkMode ? Colors.amber : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Author: ${data['author'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Upload Date: ${_formatTimestamp(data['timestamp'])}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey : Colors.grey[800],
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    trailing: GestureDetector(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.download,
                              color: isDarkMode ? Colors.amber : Colors.black,
                            ),
                            onPressed: () async {
                              // Assuming you store the PDF URL in 'pdf_url' field
                              String pdfUrl = data['pdf_url'] ?? '';
                              // Assuming you store the PDF file name in 'pdf_name' field
                              String pdfFileName = data['title'] ?? '';
                              await _downloadPdf(pdfUrl, pdfFileName);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: isDarkMode ? Colors.amber : Colors.black,
                            ),
                            onPressed: () async {
                              String pdfFilePath = await _viewPdf(
                                  data['pdf_url'] ?? '', data['title'] ?? '');

                              if (pdfFilePath.isNotEmpty) {
                                // Toggle the PDF viewer
                                setState(() {
                                  isPdfViewerOpen = !isPdfViewerOpen;
                                });

                                // If the viewer is open, navigate to the PDF viewer page
                                if (isPdfViewerOpen) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'PDF Viewer Successfully Opened'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PdfViewerPage(
                                        pdfFilePath: pdfFilePath,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          Positioned(
            bottom:
                0.0, // Adjust this value as needed for the desired bottom spacing
            left: 0,
            right: 0,
            child: Center(
              child: ScrollToTopButton(scrollController: _scrollController),
            ),
          ),
        ],
      ),
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
