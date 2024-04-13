import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/medidas.dart';
import 'package:fit_match/models/user.dart';

import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/charts/chart_medida_widget_zoom.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EstadisticasMedidasScreen extends StatefulWidget {
  final User user;
  final List<Medidas> medidas;

  const EstadisticasMedidasScreen(
      {Key? key, required this.user, required this.medidas})
      : super(key: key);

  @override
  State<EstadisticasMedidasScreen> createState() =>
      EstadisticasMedidasScreenState();
}

class EstadisticasMedidasScreenState extends State<EstadisticasMedidasScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedAtributoMedida = "weight";
  bool isLoading = false;
  bool showListTab = true;

  List<StatMedida> statMedidas = [];

  double convertUnits(String system, double value, String attribute) {
    // Asumiendo que tienes funciones fromKgToLbs y fromCmToInches definidas en alguna parte
    if (system == "imperial") {
      switch (attribute) {
        case "weight":
          return fromKgToLbs(value);
        default:
          return fromCmToInches((value));
      }
    }
    return value;
  }

  String getAttributeUnit(String system, String attribute) {
    switch (attribute) {
      case "weight":
        return system == "imperial" ? "lbs" : "kg";
      default:
        return system == "imperial" ? "in" : "cm";
    }
  }

  String getLabelByAttribute(String attribute) {
    Map<String, String> atributosEtiquetas = {
      "weight": "Peso",
      "leftArm": "Brazo izquierdo",
      "rightArm": "Brazo derecho",
      "chest": "Pecho",
      "waist": "Cintura",
      "leftLeg": "Pierna izquierda superior",
      "rightLeg": "Pierna derecha superior",
      "leftCalf": "Pantorrilla izquierda",
      "rightCalf": "Pantorrilla derecha",
      "leftForearm": "Antebrazo izquierdo",
      "rightForearm": "Antebrazo derecho",
      "shoulders": "Hombros",
      "neck": "Cuello",
    };
    return atributosEtiquetas[attribute] ?? '';
  }

  double? getAttributeValue(Medidas medida) {
    // Mapa que relaciona los nombres de los atributos con las funciones para obtener sus valores
    Map<String, double? Function(Medidas)> attributeAccessors = {
      "weight": (m) => m.weight,
      "leftArm": (m) => m.leftArm,
      "rightArm": (m) => m.rightArm,
      "chest": (m) => m.chest,
      "waist": (m) => m.waist,
      "leftLeg": (m) => m.upperLeftLeg,
      "rightLeg": (m) => m.upperRightLeg,
      "leftCalf": (m) => m.leftCalve,
      "rightCalf": (m) => m.rightCalve,
      "rightForearm": (m) => m.rightForearm,
      "leftForearm": (m) => m.leftForearm,
      "shoulders": (m) => m.shoulders,
      "neck": (m) => m.neck,
    };

    var accessor = attributeAccessors[selectedAtributoMedida];
    return accessor != null ? accessor(medida) : null;
  }

  void onAtributoChanged(String value) {
    setState(() {
      selectedAtributoMedida = value;
    });
    loadStatMedidas();
  }

  void loadStatMedidas() async {
    setState(() {
      isLoading = true;
    });

    if (widget.medidas.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    var statMedidasLoaded = <StatMedida>[];

    for (var medida in widget.medidas) {
      var value = getAttributeValue(medida);
      if (value != null) {
        double convertedValue =
            convertUnits(widget.user.system, value, selectedAtributoMedida);
        StatMedida statMedida = StatMedida(
          value: convertedValue,
          date: medida.timestamp!,
        );
        statMedidasLoaded.add(statMedida);
      }
    }

    setState(() {
      statMedidas = statMedidasLoaded;
      isLoading = false;
    });
  }

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    loadStatMedidas();
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

  //SCREEN

  @override
  Widget build(BuildContext context) {
    Map<String, String> atributosEtiquetas = {
      "weight": "Peso",
      "leftArm": "Brazo izquierdo",
      "rightArm": "Brazo derecho",
      "chest": "Pecho",
      "waist": "Cintura",
      "leftLeg": "Pierna izquierda superior",
      "rightLeg": "Pierna derecha superior",
      "leftCalf": "Pantorrilla izquierda",
      "rightCalf": "Pantorrilla derecha",
      "leftForearm": "Antebrazo izquierdo",
      "rightForearm": "Antebrazo derecho",
      "shoulders": "Hombros",
      "neck": "Cuello",
    };

    List<DropdownMenuItem<String>> dropdownItems = atributosEtiquetas.entries
        .map((entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(
                entry.value,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Estadísticas corporales",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                iconEnabledColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                value: selectedAtributoMedida,
                dropdownColor: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.background,
                focusColor: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.background,
                onChanged: (String? newValue) {
                  newValue != null ? onAtributoChanged(newValue) : null;
                  loadStatMedidas();
                },
                items: dropdownItems,
              ),
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
        children: (statMedidas.length > 1)
            ? [
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Center(child: buildGraphView(context)),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : buildListView(context),
              ]
            : [
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : buildNotEnoughData(context),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : buildListView(context),
              ],
      ),
    );
  }

  Widget buildNotEnoughData(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: const Text("No hay datos suficientes para realizar una gráfica"),
    );
  }

  Widget buildGraphView(
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ChartMedidaZoom(
        statMedidas: statMedidas,
        unit: getAttributeUnit(widget.user.system, selectedAtributoMedida),
        title: getLabelByAttribute(selectedAtributoMedida),
      ),
      //  LineChartMedidaSample(
      //   statMedidas: statMedidas,
      //   unit: getAttributeUnit(widget.user.system, selectedAtributoMedida),
      //   // title: getLabelByAttribute(selectedAtributoMedida),
      // ),
    );
  }

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
              children: buildTitleListView(),
            ),
          ),
          Expanded(
            // Hace que la lista ocupe el espacio restante
            child: ListView.builder(
              itemCount: widget.medidas.length,
              itemBuilder: (context, index) {
                final medida = widget.medidas[index];

                // Determina los widgets a incluir basado en el tipo de registro
                List<Widget> rowContent = buildListViewRowContent(medida);
                if (rowContent.isEmpty) {
                  return Container();
                }
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

  List<Widget> buildListViewRowContent(Medidas medida) {
    // Lista inicial con el widget de fecha, presente en todos los registros
    double? valorMedidaAtributo = getAttributeValue(medida);
    if (valorMedidaAtributo == null || valorMedidaAtributo == 0) return [];
    return [
      Expanded(
        flex: 2,
        child: Text(
          DateFormat.yMMMMd('es_ES').format(medida.timestamp!),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      Expanded(
        child: Text(
          "${convertUnits(widget.user.system, valorMedidaAtributo, selectedAtributoMedida)} ${getAttributeUnit(widget.user.system, selectedAtributoMedida)}",
        ),
      )
    ];
  }

  List<Widget> buildTitleListView() {
    return [
      const Expanded(
        flex: 2,
        child: Text(
          'Fecha',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Expanded(
        child: Text(
          getLabelByAttribute(selectedAtributoMedida),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }
}
