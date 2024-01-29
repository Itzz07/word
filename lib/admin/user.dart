import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word/admin/edit_user.dart';
import 'package:word/widgets/floating_button.dart';

class UserPanel extends StatefulWidget {
  final bool isDarkMode;

  const UserPanel({super.key, required this.isDarkMode});

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.indigo : Colors.indigoAccent,
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
          'User Panel',
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return UserCard(
                user: User(
                  userId: document.id,
                  name: data['name'],
                  role: data['role'],
                  profilePicture: data['profilePicture'],
                  // isDarkMode: isDarkMode,
                ),
                isDarkMode: isDarkMode,
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton:
          ScrollToTopButton(scrollController: _scrollController),
    );
  }
}

class UserCard extends StatefulWidget {
  final User user;
  final bool isDarkMode;
  const UserCard({
    super.key,
    required this.user,
    required this.isDarkMode,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Card(
      elevation: 3.0,
      color: isDarkMode ? Colors.indigo : Colors.indigoAccent,
      shadowColor: isDarkMode ? Colors.white : Colors.black,
      margin: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 20,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: widget.user.profilePicture != null &&
                  widget.user.profilePicture is String
              ? NetworkImage(widget.user.profilePicture)
              : AssetImage(
                  widget.isDarkMode ? 'assets/logo1.jpg' : 'assets/logo.jpg',
                ) as ImageProvider<Object>?,
          radius: 25,
        ),
        title: Text(
          widget.user.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          widget.user.role,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditUserPage(
                userId: widget.user.userId,
                isDarkMode: isDarkMode,
              ),
            ),
          );
        },
      ),
    );
  }
}

class User {
  final String userId;
  final String name;
  final String role;
  final String profilePicture;

  User({
    required this.userId,
    required this.name,
    required this.role,
    required this.profilePicture,
  });

  // Factory method to create a User object from a Map
  factory User.fromMap(Map<String, dynamic> map, String userId) {
    return User(
      userId: userId,
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
    );
  }

  // Convert the User object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'profilePicture': profilePicture,
      // Add any other properties you want to include
    };
  }
}
