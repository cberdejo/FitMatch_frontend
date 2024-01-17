import 'package:fit_match/models/user.dart';
import 'package:fit_match/providers/pageState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:provider/provider.dart';

class mobileLayout extends StatefulWidget {
  final User user;
  final int initialPage;

  const mobileLayout({
    Key? key,
    required this.user,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  _mobileLayout createState() => _mobileLayout();
}

class _mobileLayout extends State<mobileLayout> {
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();

    pageController = PageController(
      initialPage: Provider.of<PageState>(context, listen: false).currentPage,
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      Provider.of<PageState>(context, listen: false).currentPage = page;
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

  Widget getProfileIcon(int pageNumber) {
    int _page = Provider.of<PageState>(context).currentPage;

    // Verificar si hay una imagen de perfil
    if (pageNumber == 4 && widget.user.profile_picture.isNotEmpty == true) {
      return CircleAvatar(
        backgroundImage: NetworkImage(widget.user.profile_picture),
        radius: 16,
      );
    } else {
      // Ícono por defecto si no hay imagen de perfil
      return Icon(
        Icons.person,
        color: _page == pageNumber ? blueColor : primaryColor,
      );
    }
  }

  BottomNavigationBarItem buildTabBarItem(Widget icon, int pageNumber) {
    return BottomNavigationBarItem(icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    int _page = Provider.of<PageState>(context).currentPage;

    return Scaffold(
        body: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: buildHomeScreenItems(widget.user),
        ),
        bottomNavigationBar: CupertinoTabBar(
          backgroundColor: mobileBackgroundColor,
          items: <BottomNavigationBarItem>[
            buildTabBarItem(
                Icon(Icons.home, color: _page == 0 ? blueColor : primaryColor),
                0),
            buildTabBarItem(
                Icon(Icons.favorite,
                    color: _page == 1 ? blueColor : primaryColor),
                1),
            buildTabBarItem(
                Icon(Icons.bookmark,
                    color: _page == 2 ? blueColor : primaryColor),
                2),
            buildTabBarItem(
                Icon(Icons.fitness_center,
                    color: _page == 3 ? blueColor : primaryColor),
                3),
            buildTabBarItem(getProfileIcon(4), 4),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ));
  }
}
