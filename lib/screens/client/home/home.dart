import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/home/analiticas/medidas.dart';
import 'package:fit_match/screens/client/home/historial/historial.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/widget/card_option_home.dart';
import 'package:fit_match/widget/imagen_detailed.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final coverHeight = 200.0;
  final mobileprofileHeight = 500;
  final webProfileHeight = 550;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToHistorial() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ViewHistorialScreen(
        user: widget.user,
      ),
    ));
  }

  void _navigateToMedidas() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MedidasScreen(
        user: widget.user,
      ),
    ));
  }

  //SCREEN

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildTop(context),
            Text(
              "¡Bienvenido de nuevo, ${widget.user.username}!",
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 10.0),
            CardOption(
              title: "Historial de entrenos",
              description:
                  "Pulsa aquí para visualizar tus entrenamientos y analíticas correspondientes",
              icon: Icons.calendar_month,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => _navigateToHistorial(),
            ),
            const Divider(),
            CardOption(
              title: "Toma de medidas y progreso",
              description:
                  "Pulsa aquí para apuntar mediciones, subir fotos y ver el progreso a lo largo del tiempo",
              icon: Icons.fitness_center,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => _navigateToMedidas(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTop(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final profileHeight =
        width < webScreenSize ? mobileprofileHeight : webProfileHeight;
    final bottom = profileHeight / 6;
    final top = coverHeight - profileHeight / 3;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCover(),
        ),
        Positioned(top: top, child: buildProfileImage()),
      ],
    );
  }

  Widget buildCover() {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color lighterColor =
        Color.lerp(primaryColor, Colors.white, 0.3) ?? primaryColor;
    Color darkerColor =
        Color.lerp(primaryColor, Colors.black, 0.2) ?? primaryColor;
    return Container(
      width: double.infinity,
      height: coverHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkerColor, lighterColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          tileMode: TileMode.clamp,
        ),
      ),
    );
  }

  Widget buildProfileImage() {
    final double width = MediaQuery.of(context).size.width;
    final profileHeight =
        width < webScreenSize ? mobileprofileHeight : webProfileHeight;
    final double circleSize = profileHeight / 2;

    final double imageSize = circleSize * 0.9;
    return Stack(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        Positioned(
          left: (circleSize - imageSize) / 2,
          top: (circleSize - imageSize) / 2,
          child: ClipOval(
            child: MouseRegion(
              cursor: widget.user.profile_picture != null &&
                      widget.user.profile_picture!.isNotEmpty
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: () => widget.user.profile_picture != null &&
                        widget.user.profile_picture!.isNotEmpty
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDetail(
                              imageData: widget.user.profile_picture!),
                        ),
                      )
                    : null,
                child: Image.network(
                  widget.user.profile_picture ?? "",
                  width: imageSize, // Diámetro del círculo
                  height: imageSize,
                  fit: BoxFit
                      .cover, // Asegúrate de que la imagen cubra el círculo
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Icon(Icons.account_circle,
                        size: imageSize); // Ejemplo con un Icono
                  },
                ),
              ),
            ),
          ),
          //  CircleAvatar(
          //   radius: imageSize / 2,
          //   backgroundImage: NetworkImage(widget.user.profile_picture),
          //   backgroundColor: Theme.of(context).colorScheme.primary,
          // ),
        ),
      ],
    );
  }
}
