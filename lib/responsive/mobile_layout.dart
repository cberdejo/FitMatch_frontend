import 'package:fit_match/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/utils.dart';

class mobileLayout extends StatefulWidget {
  final User user;
  const mobileLayout({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _mobileLayout createState() => _mobileLayout();
}

class _mobileLayout extends State<mobileLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    // Animating Page
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  BottomNavigationBarItem buildTabBarItem(IconData icon, int pageNumber) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: (_page == pageNumber) ? blueColor : primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: homeScreenItems,
        ),
        bottomNavigationBar: CupertinoTabBar(
          backgroundColor: mobileBackgroundColor,
          items: <BottomNavigationBarItem>[
            buildTabBarItem(Icons.home, 0),
            buildTabBarItem(Icons.search, 1),
            buildTabBarItem(Icons.chat, 2),
            buildTabBarItem(Icons.favorite, 3),
            buildTabBarItem(Icons.bookmark, 4),
            buildTabBarItem(Icons.fitness_center, 5),
            buildTabBarItem(Icons.person, 6),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ));
  }
}
