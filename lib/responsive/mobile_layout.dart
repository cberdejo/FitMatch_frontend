import 'package:fit_match/models/user.dart';
// import 'package:fit_match/providers/notifications.dart';
import 'package:fit_match/providers/pageState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:provider/provider.dart';

class MobileLayout extends StatefulWidget {
  final User user;
  final int initialPage;

  const MobileLayout({
    Key? key,
    required this.user,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  MobileLayoutState createState() => MobileLayoutState();
}

class MobileLayoutState extends State<MobileLayout> {
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
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final secondaryColor = Theme.of(context).colorScheme.onSecondary;

    int page = Provider.of<PageState>(context).currentPage;

    // Verificar si hay una imagen de perfil
    if (pageNumber == 4 && widget.user.profile_picture != null) {
      return ClipOval(
        child: Image.network(
          widget.user.profile_picture!,
          width: 32, // Diámetro del círculo
          height: 32,
          fit: BoxFit.cover, // Asegúrate de que la imagen cubra el círculo
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            return const Icon(Icons.account_circle,
                size: 32); // Ejemplo con un Icono
          },
        ),
      );
    } else {
      // Ícono por defecto si no hay imagen de perfil
      return Icon(
        Icons.person,
        color: page == pageNumber ? primaryContainer : secondaryColor,
      );
    }
  }

  BottomNavigationBarItem buildTabBarItem(Widget icon, int pageNumber) {
    return BottomNavigationBarItem(icon: icon);
  }

  // BottomNavigationBarItem buildTabBarItemNumber(
  //     Widget icon, int pageNumber, int notifCount) {
  //   return BottomNavigationBarItem(
  //     icon: Stack(
  //       children: <Widget>[
  //         icon,
  //         if (notifCount > 0)
  //           Positioned(
  //             right: 0,
  //             child: Container(
  //               padding: const EdgeInsets.all(1),
  //               decoration: BoxDecoration(
  //                 color: Colors.red,
  //                 borderRadius: BorderRadius.circular(6),
  //               ),
  //               constraints: const BoxConstraints(
  //                 minWidth: 12,
  //                 minHeight: 12,
  //               ),
  //               child: Text(
  //                 '$notifCount',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 8,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final secondaryColor = Theme.of(context).colorScheme.onSecondary;
    int page = Provider.of<PageState>(context).currentPage;

    return Scaffold(
        body: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: buildHomeScreenItems(widget.user),
        ),
        bottomNavigationBar: CupertinoTabBar(
          backgroundColor: primaryColor,
          items: <BottomNavigationBarItem>[
            buildTabBarItem(
                Icon(Icons.home,
                    color: page == 0 ? primaryContainer : secondaryColor),
                0),
            buildTabBarItem(
                Icon(Icons.explore,
                    color: page == 1 ? primaryContainer : secondaryColor),
                1),
            buildTabBarItem(
                Icon(Icons.favorite,
                    color: page == 2 ? primaryContainer : secondaryColor),
                2),
            buildTabBarItem(
                Icon(Icons.fitness_center,
                    color: page == 3 ? primaryContainer : secondaryColor),
                3),
            buildTabBarItem(getProfileIcon(4), 4),
          ],
          onTap: navigationTapped,
          currentIndex: page,
        ));
  }
}
