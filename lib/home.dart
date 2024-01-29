import 'package:flutter/material.dart';
import 'package:word/screens/announcements.dart';
import 'package:word/screens/books.dart';
import 'package:word/screens/devotions.dart';
import 'package:word/screens/video.dart';
import 'package:word/widgets/appbar.dart';

class HomeApp extends StatefulWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  int currentPageIndex = 0;
  final PageController _pageController = PageController();
  bool isDarkMode = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color scaffoldBackgroundColor = isDarkMode ? Colors.black87 : Colors.white;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          appBar: CustomAppBar(
            onDarkModeToggle: toggleDarkMode,
            isDarkMode: isDarkMode,
          ),
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            indicatorColor: isDarkMode ? Colors.white : Colors.black,
            selectedIndex: currentPageIndex,
            surfaceTintColor: Colors.white,
            backgroundColor: isDarkMode ? Colors.amber : Colors.white,
            destinations: <NavigationDestination>[
              NavigationDestination(
                selectedIcon: const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                icon: Icon(
                  Icons.star_border,
                  color: isDarkMode ? Colors.white : Colors.amber,
                ),
                label: 'Devotions',
              ),
              NavigationDestination(
                selectedIcon: const Icon(
                  Icons.notification_important,
                  color: Colors.amber,
                ),
                icon: Icon(
                  Icons.notifications_none,
                  color: isDarkMode ? Colors.white : Colors.amber,
                ),
                label: 'Announcements',
              ),
              NavigationDestination(
                selectedIcon: const Icon(
                  Icons.video_label,
                  color: Colors.amber,
                ),
                icon: Icon(
                  Icons.video_label_outlined,
                  color: isDarkMode ? Colors.white : Colors.amber,
                ),
                label: 'Content',
              ),
              NavigationDestination(
                selectedIcon: const Icon(
                  Icons.menu_book,
                  color: Colors.amber,
                ),
                icon: Icon(
                  Icons.menu_book_outlined,
                  color: isDarkMode ? Colors.white : Colors.amber,
                ),
                label: 'Books',
              ),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            itemCount: 4,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return DevotionsPage(
                    isDarkMode: isDarkMode,
                    toggleDarkMode: toggleDarkMode,
                  );
                case 1:
                  return AnnouncementsPage(
                    isDarkMode: isDarkMode,
                    toggleDarkMode: toggleDarkMode,
                  );
                case 2:
                  return VideoPage(
                    isDarkMode: isDarkMode,
                    toggleDarkMode: toggleDarkMode,
                  );
                case 3:
                  return BooksPage(
                    backgroundColord: scaffoldBackgroundColor,
                    isDarkMode: isDarkMode,
                    toggleDarkMode: toggleDarkMode,
                  );
                default:
                  return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }
}
