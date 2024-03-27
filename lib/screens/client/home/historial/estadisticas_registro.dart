import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/registros.dart';
import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/services/registro_service.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/charts/line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EstadisticasRegistroScreen extends StatefulWidget {
  final User user;
  final SesionEntrenamiento session;

  const EstadisticasRegistroScreen(
      {Key? key, required this.user, required this.session})
      : super(key: key);

  @override
  State<EstadisticasRegistroScreen> createState() =>
      _EstadisticasRegistroScreen();
}

class _EstadisticasRegistroScreen extends State<EstadisticasRegistroScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<RegistroSet> registros = [];
  late int selectedEjercicioId;
  bool isLoading = false;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    selectedEjercicioId = getFirstNonNulldetailedExerciseId(
        widget.session.ejerciciosDetalladosAgrupados)!;
    loadRegistros();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int? getFirstNonNulldetailedExerciseId(
      List<EjerciciosDetalladosAgrupados>? agrupados) {
    if (agrupados == null) return null;

    for (var grupo in agrupados) {
      for (var ejercicioDetallado in grupo.ejerciciosDetallados) {
        if (ejercicioDetallado.detailedExerciseId != null) {
          return ejercicioDetallado.detailedExerciseId;
        }
      }
    }
    return null;
  }

  Future<void> loadRegistros() async {
    setState(() {
      isLoading = true;
    });

    try {
      registros = await RegistroMethods()
          .getAllRegistersByUserIdAndDetailedExerciseId(
              widget.user.user_id as int, selectedEjercicioId);
    } catch (e) {
      print(e);
    }

    setState(() {
      registros = registros;
      isLoading = false;
    });
  }

  Future<void> onEjercicioChanged(int? newValue) async {
    setState(() {
      selectedEjercicioId = newValue!;
    });
    await loadRegistros();
  }

  //SCREEN

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> dropdownItems = [];
    if (widget.session.ejerciciosDetalladosAgrupados != null) {
      for (var group in widget.session.ejerciciosDetalladosAgrupados!) {
        for (var exercise in group.ejerciciosDetallados) {
          dropdownItems.add(
            DropdownMenuItem(
                value: exercise.detailedExerciseId,
                child: Text(
                  exercise.ejercicio != null
                      ? exercise.ejercicio!.name
                      : "Ejercicio no especificado",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                  ),
                )),
          );
        }
      }
    }
    int registerTypeId = _getRegisterTypeOfActiveDetailedExercise();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.session.sessionName,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                iconEnabledColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                value: selectedEjercicioId,
                dropdownColor: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.background,
                focusColor: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.background,
                onChanged: (int? newValue) {
                  onEjercicioChanged(newValue);
                },
                items: dropdownItems,
              ),
              // TabBar aquí
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    text: 'Gráfico',
                    icon: Icon(Icons.bar_chart),
                  ),
                  Tab(text: 'Lista', icon: Icon(Icons.list)),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(child: buildGraphView(context)),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : buildListView(context),
        ],
      ),
    );
  }

  Widget buildGraphView(
    BuildContext context,
  ) {
    int registerTypeId = _getRegisterTypeOfActiveDetailedExercise();
    return LineChartSample(
      registroSet: registros,
      registerTypeId: registerTypeId,
      system: widget.user.system,
    );
  }

  // List<FlSpot> getSpotsFromRegistros(
  //     List<RegistroSet> registros, int registerTypeId) {
  //   return registros.asMap().entries.map((entry) {
  //     // int index = entry.key;
  //     double value = 0.0; // Inicialización predeterminada
  //     double date = entry.value.timestamp.millisecondsSinceEpoch.toDouble();

  //     switch (registerTypeId) {
  //       case 4: // AMRAP: usar 'reps'
  //         value = entry.value.reps?.toDouble() ?? 0.0;
  //         break;
  //       case 5:
  //         value = entry.value.time ?? 0.0;
  //       case 6:
  //         value = entry.value.time ?? 0.0;
  //         break;
  //       default: // Otro tipo: usar 'weight' si eso tiene sentido
  //         value = (entry.value.weight?.toDouble() ?? 0.0) *
  //             (entry.value.reps?.toDouble() ?? 0.0);
  //         break;
  //     }

  //     return FlSpot(date, value);
  //   }).toList();
  // }

  Widget buildListView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buildTitleListView(
                  _getRegisterTypeOfActiveDetailedExercise()),
            ),
          ),
          Expanded(
            // Hace que la lista ocupe el espacio restante
            child: ListView.builder(
              itemCount: registros.length,
              itemBuilder: (context, index) {
                final registro = registros[index];

                // Determina los widgets a incluir basado en el tipo de registro
                List<Widget> rowContent = buildListViewRowContent(registro);

                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: rowContent,
                  ),
                  subtitle: const Divider(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getRegisterTypeOfActiveDetailedExercise() {
    for (var group in widget.session.ejerciciosDetalladosAgrupados!) {
      for (var exercise in group.ejerciciosDetallados) {
        if (exercise.detailedExerciseId == selectedEjercicioId) {
          return exercise.registerTypeId;
        }
      }
    }
    return 0;
  }

  List<Widget> _getTitlesBasedInRegisterType(int registerTypeId) {
    switch (registerTypeId) {
      case 4: // AMRAP
        return [
          const Expanded(
            child: Text(
              "AMRAP",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      case 5: // Tiempo
        return [
          const Expanded(
            child: Text(
              "Tiempo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      case 6: // Rango de tiempo
        return [
          const Expanded(
            child: Text(
              "Tiempo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              "Peso",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      default: // Para los demás casos
        return [
          const Expanded(
            child: Text(
              "Repeticiones",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              "Peso",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
    }
  }

  List<Widget> buildListViewRowContent(RegistroSet registro) {
    // Lista inicial con el widget de fecha, presente en todos los registros
    List<Widget> rowContent = [
      Expanded(
        flex: 2,
        child: Text(
          DateFormat.yMMMMd('es_ES').format(registro.timestamp),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    ];

    switch (_getRegisterTypeOfActiveDetailedExercise()) {
      case 4: // AMRAP
        rowContent.add(
          const Expanded(
            child: Text("AMRAP", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
        break;
      case 5: // Tiempo
        rowContent.add(
          Expanded(
            child: Text("${registro.time} min",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
        break;
      case 6: // Rango de tiempo
        rowContent.addAll([
          Expanded(
            child: Text("${registro.time} min",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text("${_getWeight(registro.weight!)} ${_getSystemUnit()}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]);
        break;
      default: // Otro tipo
        rowContent.addAll([
          Expanded(
            child: Text("${registro.reps} reps",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text("${_getWeight(registro.weight!)} ${_getSystemUnit()}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]);
    }

    return rowContent;
  }

  List<Widget> buildTitleListView(int registerTypeId) {
    // Obtener los widgets basados en el tipo de registro
    List<Widget> titles = _getTitlesBasedInRegisterType(registerTypeId);

    // Comenzamos con el widget de 'Fecha'
    List<Widget> listViewTitles = [
      const Expanded(
        flex: 2,
        child: Text(
          'Fecha',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];

    // Añadir los widgets obtenidos a la lista
    listViewTitles.addAll(titles);

    return listViewTitles;
  }

  _getWeight(double weight) {
    if (widget.user.system == 'imperial') {
      return fromKgToLbs(weight);
    } else if (widget.user.system == 'metrico') {
      return weight;
    }
  }

  _getSystemUnit() {
    if (widget.user.system == 'imperial') {
      return 'lbs';
    } else if (widget.user.system == 'metrico') {
      return 'kg';
    }
  }
}




 // return Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: LineChart(
    //     LineChartData(
    //       gridData: const FlGridData(show: false),
    //       titlesData: FlTitlesData(
    //         bottomTitles: AxisTitles(
    //           sideTitles: SideTitles(
    //             showTitles: true,
    //             getTitlesWidget: (value, meta) {
    //               // Formato para el eje X (tiempo)
    //               final DateTime date =
    //                   DateTime.fromMillisecondsSinceEpoch(value.toInt());
    //               return SideTitleWidget(
    //                 axisSide: meta.axisSide,
    //                 child: Text(DateFormat.MMMd().format(date)),
    //               );
    //             },
    //             reservedSize: 32,
    //           ),
    //         ),
    //         leftTitles: AxisTitles(
    //           sideTitles: SideTitles(
    //             showTitles: true,
    //             getTitlesWidget: (value, meta) {
    //               // Etiquetas para el eje Y varían según el tipo de registro
    //               String title = "";
    //               switch (registerTypeId) {
    //                 case 4: // AMRAP: 'Reps'
    //                   title = "$value";
    //                   break;
    //                 case 5: // Tiempo: 'Minutos'
    //                   title = "${value.toInt()} min";
    //                   break;
    //                 case 6: // Rango de tiempo: igual que tiempo
    //                   title = "${value.toInt()} min";
    //                   break;
    //                 default: // Otro tipo: 'Peso'
    //                   title = "$value kg";
    //                   break;
    //               }
    //               return SideTitleWidget(
    //                 axisSide: meta.axisSide,
    //                 child: Text(title),
    //               );
    //             },
    //             reservedSize: 40,
    //           ),
    //         ),
    //       ),
    //       borderData: FlBorderData(show: false),
    //       lineBarsData: [
    //         LineChartBarData(
    //           spots: spots,
    //           isCurved: true,
    //           color: Theme.of(context).colorScheme.primary,
    //           dotData: const FlDotData(show: true),
    //           belowBarData: BarAreaData(show: false),
    //         ),
    //       ],
    //       lineTouchData: const LineTouchData(
    //         enabled: true,
    //         touchTooltipData: LineTouchTooltipData(
    //             // Configuraciones para el tooltip al tocar
    //             ),
    //       ),
    //       // Habilitar el zoom y el desplazamiento
    //       // Ajusta el rango de zoom y el rango de desplazamiento según lo necesites
    //       minX: minX,
    //       maxX: minX + visibleRangeX, // Ajuste basado en el factor de zoom
    //       minY: minY,
    //       maxY: minY + visibleRangeY, // Ajuste basado en el factor de zoom
    //       clipData: const FlClipData.all(),
    //     ),
    //   ),
    // );