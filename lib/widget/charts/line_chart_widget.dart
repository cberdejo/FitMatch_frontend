import 'dart:math';

import 'package:fit_match/models/registros.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartSample extends StatefulWidget {
  final List<RegistroSet> registroSet;
  final int registerTypeId;
  final String system;
  const LineChartSample(
      {super.key,
      required this.registroSet,
      required this.registerTypeId,
      required this.system});

  @override
  State<LineChartSample> createState() => _LineChartSample();
}

class _LineChartSample extends State<LineChartSample> {
  List<Color> gradientColors = [
    const Color(0xFF50E4FF),
    const Color(0xFF2196F3),
  ];

  late double originalMinX;
  late double originalMaxX;
  late double originalMinY;
  late double originalMaxY;

  late List<FlSpot> spots;
  late String system;
  double marginFactor = 0.10; // El margen es el 5% del rango total

  List<FlSpot> getSpotsFromRegistros(
      List<RegistroSet> registros, int registerTypeId) {
    return registros
        .asMap()
        .entries
        .map((entry) {
          // int index = entry.key;
          double value = 0.0; // Inicialización predeterminada

          double date = entry.value.timestamp.millisecondsSinceEpoch.toDouble();

          switch (registerTypeId) {
            case 4: // AMRAP: usar 'reps'
              value = 1;
              break;
            case 5: // Tiempo
              value =
                  entry.value.time != null ? entry.value.time!.toDouble() : 0.0;
              break;
            case 6: // rango Tiempo
              value = (entry.value.time?.toDouble() ?? 0.0) *
                  (entry.value.weight?.toDouble() ?? 0.0);

              break;
            default: // Otro tipo: usar 'weight' si eso tiene sentido
              value = (entry.value.weight?.toDouble() ?? 0.0) *
                  (entry.value.reps?.toDouble() ?? 0.0);
              break;
          }
          return FlSpot(date, value);
        })
        .where((spot) => spot.y > 0)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _initSystem();
    _initSpots();
  }

  _initSystem() {
    system = widget.system == 'metrico' ? 'kg' : 'lbs';
  }

  _initSpots() {
    List<FlSpot> spotsSinNormalizar =
        getSpotsFromRegistros(widget.registroSet, widget.registerTypeId);
    //deberían estar ordenados pero por si acaso
    spotsSinNormalizar.sort((a, b) => a.x.compareTo(b.x));

    // Un pequeño valor para incrementar los puntos con el mismo valor de x.
    double increment = 0.001;
    //Para que no tengan los mismos valores de x
    for (int i = 1; i < spotsSinNormalizar.length; i++) {
      if (spotsSinNormalizar[i].x == spotsSinNormalizar[i - 1].x) {
        // Encuentra el próximo valor único de x incrementando ligeramente.
        double nextUniqueX = spotsSinNormalizar[i].x + increment;
        // Asegúrate de que este nuevo valor también sea único.
        while (spotsSinNormalizar.any((spot) => spot.x == nextUniqueX)) {
          nextUniqueX += increment;
        }
        // Asigna el nuevo valor único a x.
        spotsSinNormalizar[i] = FlSpot(nextUniqueX, spotsSinNormalizar[i].y);
      }
    }

    // Ahora puedes proceder con la normalización y otros pasos como antes.

    originalMinX = spotsSinNormalizar.isNotEmpty
        ? spotsSinNormalizar.map((spot) => spot.x).reduce(min)
        : 0.0;
    originalMaxX = spotsSinNormalizar.isNotEmpty
        ? spotsSinNormalizar.map((spot) => spot.x).reduce(max)
        : 0.0;

    originalMinY = spotsSinNormalizar.isNotEmpty
        ? spotsSinNormalizar.map((spot) => spot.y).reduce(min)
        : 0.0;
    originalMaxY = spotsSinNormalizar.isNotEmpty
        ? spotsSinNormalizar.map((spot) => spot.y).reduce(max)
        : 0.0;

    // Incrementa ligeramente el rango de los valores min y max para el eje X
    const double paddingX = 0.05; // 5% de padding
    double rangeX = originalMaxX - originalMinX;
    double paddingAmountX = rangeX * paddingX;
    originalMinX -= paddingAmountX;
    originalMaxX += paddingAmountX;

    double rangeY = originalMaxY - originalMinY;
    double paddingAmountY =
        rangeY * paddingX; // Asumiendo el mismo porcentaje de padding
    originalMinY -= paddingAmountY;
    originalMaxY += paddingAmountY;

    spots = spotsSinNormalizar.map((spot) {
      double x = normalizeTimestamp(spot.x, originalMinX, originalMaxX, 0, 10);
      double y = system == 'metrico' ? spot.y : fromKgToLbs(spot.y);
      return FlSpot(x, y);
    }).toList();
  }

  String _getTitle() {
    String title = "(repes x $system)";
    switch (widget.registerTypeId) {
      case 4: // AMRAP: usar 'reps'
        title = "Armrap";
        break;
      case 5: // Tiempo
        title = "minutos";
        break;
      case 6: // rango Tiempo
        title = "( minutos x  $system)";

        break;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double aspectRatio = width > webScreenSize ? 1.70 : 0.75;
    final int totalLabels = spots.length;
    final String title = _getTitle();
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              mainData(aspectRatio, totalLabels),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 10,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  double normalizeTimestamp(double value, double minOriginal,
      double maxOriginal, double minNew, double maxNew) {
    if (maxOriginal == minOriginal) {
      return minNew;
    }
    return (value - minOriginal) /
            (maxOriginal - minOriginal) *
            (maxNew - minNew) +
        minNew;
  }

  double desnormalizeValue(double normalizedValue, double originalMin,
      double originalMax, double newMin, double newMax) {
    // Verifica si el rango original es de un solo punto
    if (originalMin == originalMax) {
      // Devuelve el valor único, ya que no hay un rango para mapear
      return originalMin;
    }

    // Procede con la desnormalización si hay un rango válido
    return originalMin +
        ((normalizedValue - newMin) *
            (originalMax - originalMin) /
            (newMax - newMin));
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onBackground,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    // Calcula los valores extremos desnormalizados
    double minXDesnormalized =
        desnormalizeValue(0, originalMinX, originalMaxX, 0, 10);
    double maxXDesnormalized =
        desnormalizeValue(10, originalMinX, originalMaxX, 0, 10);

    // Convierte el valor de vuelta a un timestamp para la fecha
    var date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    var formattedDate = DateFormat("MMM d").format(date);

    // // Evita mostrar la etiqueta si el valor es muy cercano a los extremos desnormalizados
    // if (value <=
    //         minXDesnormalized + marginFactor * (originalMaxX - originalMinX) ||
    //     value >=
    //         maxXDesnormalized - marginFactor * (originalMaxX - originalMinX)) {
    //   return const SizedBox.shrink();
    // }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(formattedDate, style: style),
    );
  }

  Widget leftTitleWidgets(
    double value,
    TitleMeta meta,
  ) {
    return const SizedBox.shrink();
  }

  LineChartData mainData(double aspectRatio, int totalLabels) {
    double minX =
        spots.isNotEmpty ? spots.map((spot) => spot.x).reduce(min) : 0.0;
    double maxX =
        spots.isNotEmpty ? spots.map((spot) => spot.x).reduce(max) : 0.0;
    double rangeX = maxX - minX; // El rango total en el eje X
    minX -= rangeX * marginFactor; // Resta el margen al mínimo
    maxX += rangeX * marginFactor; // Añade el margen al máximo

    double minY =
        spots.isNotEmpty ? spots.map((spot) => spot.y).reduce(min) : 0.0;
    double maxY =
        spots.isNotEmpty ? spots.map((spot) => spot.y).reduce(max) : 0.0;
    double rangeY = maxY - minY; // El rango total en el eje Y
    minY -= rangeY * marginFactor; // Resta el margen al mínimo
    maxY += rangeY * marginFactor; // Añade el margen al máximo
    // double visibleRange =
    //     originalMaxX - originalMinX; // Actualiza esto según el zoom

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueAccent,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final dataIndex = spots.indexWhere(
                  (spot) => spot.x == barSpot.x && spot.y == barSpot.y);
              if (dataIndex != -1) {
                final data = widget.registroSet[dataIndex];
                // Asumiendo que 'fromKgToLbs' maneja correctamente valores nulos o esto se ajusta antes de la llamada
                final weightText = widget.system == 'metrico'
                    ? (data.weight ?? 0.0)
                    : fromKgToLbs(data.weight ?? 0.0);
                final system = widget.system == 'metrico'
                    ? 'kg'
                    : 'lbs'; // Asegúrate de que esta variable 'system' esté definida correctamente en tu código
                String text = "${data.reps ?? 0} repes x $weightText $system";

                switch (widget.registerTypeId) {
                  case 4: // AMRAP: usar 'reps'
                    text = "AMRAP: ${data.reps ?? 0} repes";
                    break;
                  case 5: // Tiempo
                    text = "${data.time ?? 0} minutos";
                    break;
                  case 6: // Rango de Tiempo
                    text = "${data.time ?? 0} minutos x $weightText $system";
                    break;
                }

                return LineTooltipItem(
                  text,
                  TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                );
              }

              return null;
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true, // Habilitar la visualización de los puntos
            getDotPainter: (spot, percent, barData, index) {
              // Personaliza cómo se dibuja cada punto aquí
              return FlDotCirclePainter(
                radius:
                    4, // El radio del punto, ajusta esto para hacer puntos más grandes
                color: Colors.white, // Color del centro del punto
                strokeWidth: 2, // El grosor del borde del punto
                strokeColor: Colors.black, // Color del borde del punto
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
