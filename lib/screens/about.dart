import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Member {
  final String name;
  final String position;
  final String profileImage;

  Member({
    required this.name,
    required this.position,
    required this.profileImage,
  });
}

class AboutPage extends StatefulWidget {
  final bool isDarkMode;

  const AboutPage({super.key, required this.isDarkMode});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  // Sample list of members
  final List<Member> members = [
    Member(
      name: 'John Doe',
      position: 'Founder',
      profileImage: 'assets/profile.jpg',
    ),
    Member(
      name: 'Jane Smith',
      position: 'Secretary',
      profileImage: 'assets/profile.jpg',
    ),
    Member(
      name: 'Bob Johnson',
      position: 'Treasurer',
      profileImage: 'assets/profile.jpg',
    ),
    // Add more members as needed
  ];

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
          'The Ministry',
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
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Ministry Information Section
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('about').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData ||
                    (snapshot.data as QuerySnapshot).docs.isEmpty) {
                  return const Text('No ministry information available.');
                }

                var aboutInfo = (snapshot.data as QuerySnapshot).docs.first;
                var ministryName = aboutInfo['ministryName'];
                var motto = aboutInfo['motto'];
                var paragraph = aboutInfo['paragraph'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      ministryName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.amber : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'motto: $motto',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'About Us:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.amber : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      paragraph,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Members Section
                    Text(
                      'Members',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.amber : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Use a PageView.builder for horizontal swiping between members
                    // Container(
                    //   color: isDarkMode ? Colors.black : Colors.white,
                    //   height: 200,
                    //   child: PageView.builder(
                    //     itemCount: members.length,
                    //     controller: PageController(
                    //         viewportFraction:
                    //             0.6), // Adjust the fraction as needed
                    //     itemBuilder: (context, index) {
                    //       final member = members[index];
                    //       return Card(
                    //         color: isDarkMode ? Colors.white24 : Colors.amber,
                    //         elevation: 4,
                    //         margin: const EdgeInsets.symmetric(horizontal: 8),
                    //         child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             // Circular profile image
                    //             ClipOval(
                    //               child: Image.asset(
                    //                 member.profileImage,
                    //                 height: 80,
                    //                 width: 80,
                    //                 fit: BoxFit.cover,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 8),
                    //             // Position and Name with color
                    //             Text(
                    //               member.position,
                    //               style: TextStyle(
                    //                 fontSize: 18,
                    //                 color: isDarkMode
                    //                     ? Colors.amber
                    //                     : Colors.white,
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //             ),
                    //             Text(
                    //               member.name,
                    //               style: TextStyle(
                    //                 fontSize: 16,
                    //                 color: isDarkMode
                    //                     ? Colors.grey
                    //                     : Colors.white70,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    _buildMembersCardList(),
                    const SizedBox(height: 24),
                    Text(
                      'Social Media',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.amber : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // facebook
                        GestureDetector(
                          onTap: () {
                            _launchURL(
                                'https://www.facebook.com/RevelationWordGlobal?mibextid=ZbWKwL');
                          },
                          child: Image.asset('assets/facebook.png',
                              height: 40, width: 40),
                        ),
                        // instagram
                        GestureDetector(
                          onTap: () {
                            // Handle Instagram press
                            _launchURL(
                                'https://instagram.com/revelationwordglobal?igshid=NzZlODBkYWE4Ng==');
                          },
                          child: Image.asset('assets/instagram.png',
                              height: 40, width: 40),
                        ),
                        // gmail
                        GestureDetector(
                          onTap: () {
                            _launchURL('mailto:zimbadaniel37@gmail.com');
                          },
                          child: Image.asset('assets/gmail.png',
                              height: 40, width: 40),
                        ),
                        // tiktok
                        GestureDetector(
                          onTap: () {
                            _launchURL(
                                'https://www.tiktok.com/@revelationwordglobal?_t=8hr2Yxe65Mj&_r=1');
                          },
                          child: Image.asset('assets/tiktok.png',
                              height: 40, width: 40),
                        ),
                        // cell
                        GestureDetector(
                          onTap: () {
                            _launchURL('tel:+260956348796');
                          },
                          child: Image.asset('assets/cell.png',
                              height: 40,
                              width:
                                  40), // Replace with the actual path to your phone icon image
                        ),
                        // whatsapp
                        GestureDetector(
                          onTap: () {
                            _launchURL('https://wa.me/message/EGZ5XH36UJHTK1');
                          },
                          child: Image.asset('assets/whatsapp.png',
                              height: 40, width: 40),
                        ),
                        // Add more social media icons as needed
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildMembersCardList() {
    final isDarkMode = widget.isDarkMode;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('members').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No members found"));
        }

        return Container(
          color: isDarkMode ? Colors.black : Colors.white,
          height: 250,
          child: PageView.builder(
            itemCount: snapshot.data!.docs.length,
            controller: PageController(viewportFraction: 0.6),
            itemBuilder: (context, index) {
              var member = snapshot.data!.docs[index];
              var name = member['name'];
              var position = member['position'] ?? '';
              var whatsapp = member['whatsapp'] ?? '';
              var email = member['email'] ?? '';
              var imageUrl = member['imageUrl'] ?? 'assets/default_image.png';

              return Card(
                color: isDarkMode ? Colors.white24 : Colors.amber,
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular profile image
                    ClipOval(
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.isDarkMode
                                  ? 'assets/logo1.jpg'
                                  : 'assets/logo.jpg',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 8),
                    // Position and Name with color
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.amber : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey : Colors.white70,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // gmail
                        GestureDetector(
                          onTap: () {
                            _launchURL('mailto:$email');
                          },
                          child: Image.asset('assets/gmail.png',
                              height: 40, width: 40),
                        ),
                        // cell
                        GestureDetector(
                          onTap: () {
                            _launchURL('tel:+26$whatsapp');
                          },
                          child: Image.asset('assets/cell.png',
                              height: 40,
                              width:
                                  40), // Replace with the actual path to your phone icon image
                        ),
                        // whatsapp
                        // GestureDetector(
                        //   onTap: () {
                        //     _launchURL('https://wa.me/message/EGZ5XH36UJHTK1');
                        //   },
                        //   child: Image.asset('assets/whatsapp.png',
                        //       height: 40, width: 40),
                        // ),
                        // Add more social media icons as needed
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
