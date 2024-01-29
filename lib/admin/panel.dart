import 'package:flutter/material.dart';
import 'package:word/admin/about.dart';
import 'package:word/admin/announce.dart';
import 'package:word/admin/books.dart';
import 'package:word/admin/devotion.dart';
import 'package:word/admin/members.dart';
import 'package:word/admin/user.dart';
import 'package:word/admin/videos.dart';

class AdminPanelPage extends StatefulWidget {
  final bool isDarkMode;
  const AdminPanelPage({super.key, required this.isDarkMode});
  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.amber : Colors.amberAccent,
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
          'Admin Panel',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildCategoryBox(context, 'Devotion', Colors.blue, Icons.add),
            _buildCategoryBox(context, 'Announcement', Colors.green, Icons.add),
            _buildCategoryBox(context, 'Members', Colors.orange, Icons.add),
            _buildCategoryBox(context, 'Books', Colors.purple, Icons.add),
            _buildCategoryBox(context, 'Content', Colors.teal, Icons.add),
            _buildCategoryBox(context, 'Users', Colors.indigo, Icons.add),
            _buildCategoryBox(context, 'About', Colors.red, Icons.add),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBox(
      BuildContext context, String category, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        _handleCategoryTap(context, category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCategoryTap(
    BuildContext context,
    String category,
  ) {
    switch (category) {
      case 'Devotion':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DevotionPanel(isDarkMode: widget.isDarkMode),
          ),
        );
      case 'Announcement':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AnnouncementPanel(isDarkMode: widget.isDarkMode),
          ),
        );
        break;
      case 'Members':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MembersPanel(isDarkMode: widget.isDarkMode),
          ),
        );
        break;
      case 'Books':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookPanel(isDarkMode: widget.isDarkMode),
          ),
        );
        break;
      case 'Content':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideosPanel(isDarkMode: widget.isDarkMode),
            // builder: (context) => VideoPanel(),
          ),
        );
        break;
      case 'Users':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserPanel(isDarkMode: widget.isDarkMode),
          ),
        );
        break;
      case 'About':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AboutPanel(isDarkMode: widget.isDarkMode),
          ),
        );
        break;
    }
  }
}
