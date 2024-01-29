import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutPanel extends StatefulWidget {
  final bool isDarkMode;

  const AboutPanel({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _AboutPanelState createState() => _AboutPanelState();
}

class _AboutPanelState extends State<AboutPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ministryNameController;
  late TextEditingController _mottoController;
  late TextEditingController _paragraphController;
  final String _selectedItemId =
      "GcFtUx3rSPb7YSKVurFF"; // Document ID to update

  @override
  void initState() {
    super.initState();
    _ministryNameController = TextEditingController();
    _mottoController = TextEditingController();
    _paragraphController = TextEditingController();
    _loadAboutData();
  }

  Future<void> _loadAboutData() async {
    try {
      // Fetch existing data from Firestore based on the document ID
      DocumentSnapshot aboutSnapshot = await FirebaseFirestore.instance
          .collection('about')
          .doc(_selectedItemId)
          .get();

      // Set the existing data to the controllers
      Map<String, dynamic> data = aboutSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _ministryNameController.text = data['ministryName'];
        _mottoController.text = data['motto'];
        _paragraphController.text = data['paragraph'];
      });
    } catch (e) {
      // Handle error
      print('Error loading about data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.red : Colors.redAccent,
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
          'About Panel',
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
                  color: isDarkMode ? Colors.red : Colors.redAccent,
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _ministryNameController,
                          autocorrect: true,
                          decoration: const InputDecoration(
                            labelText: 'Name of the Ministry',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _mottoController,
                          autocorrect: true,
                          decoration: const InputDecoration(
                            labelText: 'Motto',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _paragraphController,
                          autocorrect: true,
                          decoration: const InputDecoration(
                            labelText: 'Paragraph',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          maxLines: 10,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a paragraph';
                            }
                            return null;
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
                            'Update',
                            style: TextStyle(
                              fontSize: 20,
                              color: isDarkMode ? Colors.red : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Updating an existing entry
      FirebaseFirestore.instance
          .collection("about")
          .doc(_selectedItemId)
          .update({
        'ministryName': _ministryNameController.text,
        'motto': _mottoController.text,
        'paragraph': _paragraphController.text,
      }).then((_) {
        // Show a SnackBar to indicate successful submission
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('About information updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        print("Error updating document: $error");
      });
    } else {
      // Show a SnackBar to indicate validation error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
