import 'package:fit_match/models/user.dart';
import 'package:fit_match/providers/pageState.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WebLayout extends StatefulWidget {
  final User user;
  final int initialPage;
  const WebLayout({Key? key, required this.user, this.initialPage = 0})
      : super(key: key);

  @override
  WebLayoutState createState() => WebLayoutState();
}

class WebLayoutState extends State<WebLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    _page = Provider.of<PageState>(context, listen: false).currentPage;
    pageController = PageController(initialPage: _page);
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
    if (mounted) {
      pageController.jumpToPage(page);
    }
  }

  Widget menuItem(IconData icon, String label, int pageNumber, Color color) {
    _page = Provider.of<PageState>(context, listen: false).currentPage;
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
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: 32,
        )
      ],
    );
  }

  Widget profileMenuItem() {
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final secondaryColor = Theme.of(context).colorScheme.onSecondary;

    return InkWell(
      onTap: () => navigationTapped(4),
      child: Column(
        children: [
          if (widget.user.profile_picture == null)
            Icon(
              Icons.person,
              color: (_page == 4) ? primaryContainer : secondaryColor,
              size: 30,
            ),
          if (widget.user.profile_picture != null)
            ClipOval(
              child: Image.network(
                widget.user.profile_picture!,
                width: 40, // Diámetro del círculo
                height: 40,
                fit:
                    BoxFit.cover, // Asegúrate de que la imagen cubra el círculo
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return const Icon(Icons.account_circle, size: 40);
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.user.username,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: (_page == 4) ? primaryContainer : secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final onSecondaryColor = Theme.of(context).colorScheme.onSecondary;

    Color lighterColor =
        Color.lerp(primaryColor, Colors.white, 0.3) ?? primaryColor;
    Color darkerColor =
        Color.lerp(primaryColor, Colors.black, 0.2) ?? primaryColor;
    _page = Provider.of<PageState>(context, listen: false).currentPage;
    return Scaffold(
      body: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [darkerColor, lighterColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  tileMode: TileMode.clamp,
                ),
              ),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  InkWell(
                    onTap: () {
                      navigationTapped(0);
                    },
                    child: Text(
                      'Fit-Match',
                      style: TextStyle(
                          color: onSecondaryColor,
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
                      color: onSecondaryColor,
                      height: 64,
                    ),
                  ),
                  const SizedBox(height: 20),
                  widget.user.profile_id == 1
                      ? Column(children: [
                          menuItem(
                            Icons.history,
                            'Registros',
                            0,
                            (_page == 0) ? primaryContainer : onSecondaryColor,
                          ),
                          menuItem(
                            Icons.person,
                            'Usuarios',
                            1,
                            (_page == 1) ? primaryContainer : onSecondaryColor,
                          ),
                          menuItem(
                            Icons.remove_red_eye_outlined,
                            'Visualizar plantillas',
                            2,
                            (_page == 2) ? primaryContainer : onSecondaryColor,
                          ),
                          menuItem(
                            Icons.fitness_center,
                            'Ejercicios',
                            3,
                            (_page == 3) ? primaryContainer : onSecondaryColor,
                          ),
                          profileMenuItem(),
                        ])
                      : Column(
                          children: [
                            menuItem(
                              Icons.home,
                              'Inicio',
                              0,
                              (_page == 0)
                                  ? primaryContainer
                                  : onSecondaryColor,
                            ),
                            menuItem(
                              Icons.explore,
                              'Explorar',
                              1,
                              (_page == 1)
                                  ? primaryContainer
                                  : onSecondaryColor,
                            ),
                            menuItem(
                              Icons.favorite,
                              'Notificaciones',
                              2,
                              (_page == 2)
                                  ? primaryContainer
                                  : onSecondaryColor,
                            ),
                            menuItem(
                              Icons.fitness_center,
                              'Entrenamientos',
                              3,
                              (_page == 3)
                                  ? primaryContainer
                                  : onSecondaryColor,
                            ),
                            profileMenuItem(),
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
              children: widget.user.profile_id == 1
                  ? buildAdminScreenItems(widget.user)
                  : buildHomeScreenItems(widget.user),
            ),
          ),
        ],
      ),
    );
  }
}
