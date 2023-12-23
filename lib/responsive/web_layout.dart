import 'package:fit_match/models/user.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/utils/colors.dart';

class WebLayout extends StatefulWidget {
  final User user;

  const WebLayout({Key? key, required this.user}) : super(key: key);

  @override
  _WebLayoutState createState() => _WebLayoutState();
}

class _WebLayoutState extends State<WebLayout> {
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
    if (mounted) {
      pageController.jumpToPage(page);
    }
  }

  Widget menuItem(IconData icon, String label, int pageNumber, Color color) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: () => navigationTapped(pageNumber),
        ),
        Text(
          label,
          style: TextStyle(color: color),
        ),
        const SizedBox(
          height: 32,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              width: 200,
              color: webBackgroundColor,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  InkWell(
                    onTap: () {
                      navigationTapped(0);
                    },
                    child: const Text(
                      'Fit-Match',
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InkWell(
                    onTap: () {
                      navigationTapped(0);
                    },
                    child: Image.asset(
                      'assets/images/logo.png',
                      color: primaryColor,
                      height: 64,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      menuItem(
                        Icons.home,
                        'Inicio',
                        0,
                        (_page == 0) ? blueColor : Colors.grey,
                      ),
                      menuItem(
                        Icons.search,
                        'Búsqueda',
                        1,
                        (_page == 1) ? blueColor : Colors.grey,
                      ),
                      menuItem(
                        Icons.message,
                        'Chat',
                        2,
                        (_page == 2) ? blueColor : Colors.grey,
                      ),
                      menuItem(
                        Icons.favorite,
                        'Notificaciones',
                        3,
                        (_page == 3) ? blueColor : Colors.grey,
                      ),
                      menuItem(
                        Icons.bookmark,
                        'Guardados',
                        4,
                        (_page == 4) ? blueColor : Colors.grey,
                      ),
                      menuItem(
                        Icons.fitness_center,
                        'Entrenamientos',
                        5,
                        (_page == 5) ? blueColor : Colors.grey,
                      ),
                      menuItem(
                        Icons.person,
                        'Perfil',
                        6,
                        (_page == 6) ? blueColor : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 9,
            child: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              children: homeScreenItems,
            ),
          ),
        ],
      ),
    );
  }
}
