import 'package:fit_match/models/medidas.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/home/analiticas/estadisticas_medidas.dart';
import 'package:fit_match/screens/client/home/analiticas/nuevasMedidas.dart';
import 'package:fit_match/services/medidas_service.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/exercise_card/medida_card.dart';
import 'package:flutter/material.dart';

class MedidasScreen extends StatefulWidget {
  final User user;

  const MedidasScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<MedidasScreen> createState() => _MedidasScreen();
}

class _MedidasScreen extends State<MedidasScreen> {
  bool isLoading = true;
  List<Medidas> medidas = [];

  @override
  void initState() {
    _initMedidas();
    super.initState();
  }

  void _initMedidas() async {
    setState(() {
      isLoading = true;
    });
    List<Medidas> medidas =
        await MedidasMethods().getAllMedidas(widget.user.user_id as int);
    setState(() {
      this.medidas = medidas;
      isLoading = false;
    });
  }

  Future<void> onDelete(int measurementId) async {
    bool exito = await MedidasMethods().deleteMedidas(measurementId);
    if (exito) {
      setState(() {
        medidas
            .removeWhere((element) => element.measurementId == measurementId);
      });
      showToast(context, 'Medida eliminada', exitoso: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Medidas guardadas",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: buildViewMedidas(context),
    );
  }

  Widget buttonAdd(String label, VoidCallback onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary,
          ),
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildViewMedidas(BuildContext context) {
    if (medidas.isEmpty && !isLoading) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              buttonAdd("Añadir nuevas medidas", () => _addMedida(context),
                  Icons.add),
              const SizedBox(height: 20),
              const Text(
                'No hay datos Todavía',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            buttonAdd(
              "Añadir nuevas medidas",
              () => _addMedida(context),
              Icons.add,
            ),
            buttonAdd(
              "Ver estadísticas",
              () => _viewEstadistica(context),
              Icons.bar_chart,
            ),
            const SizedBox(height: 20),
            Column(
              children: medidas
                  .map((medida) => MedidaCard(
                        medida: medida,
                        user: widget.user,
                        onDelete: onDelete,
                        onEdit: (medida) => _addMedida(context, medida: medida),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
    }
  }

  _addMedida(BuildContext context, {Medidas? medida}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NuevaMedidaScreen(user: widget.user, medida: medida),
      ),
    ).then((result) {
      if (result == true) {
        _initMedidas();
      }
    });
  }

  _viewEstadistica(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstadisticasMedidasScreen(
          user: widget.user,
          medidas: medidas,
        ),
      ),
    );
  }
}
