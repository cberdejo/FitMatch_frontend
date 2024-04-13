import 'dart:math';

import 'package:fit_match/models/medidas.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartMedidaSample extends StatefulWidget {
  final List<StatMedida> statMedidas;
  final String unit;

  const LineChartMedidaSample({
    super.key,
    required this.statMedidas,
    required this.unit,
  });

  @override
  State<LineChartMedidaSample> createState() => LineChartState();
}

class LineChartState extends State<LineChartMedidaSample> {
  List<Color> gradientColors = [
    const Color(0xFF50E4FF),
    const Color(0xFF2196F3),
  ];

  late double originalMinX;
  late double originalMaxX;
  late double originalMinY;
  late double originalMaxY;
  double marginFactor = 0.10; // El margen es el 5% del rango total

  late List<FlSpot> spots;
  late String system;

  List<FlSpot> getSpotsFromStatsMedida(List<StatMedida> medidas) {
    return medidas
        .asMap()
        .entries
        .map((entry) {
          double value = entry.value.value;
          double date = entry.value.date.millisecondsSinceEpoch.toDouble();

          return FlSpot(date, value);
        })
        .where((spot) => spot.y > 0)
        .toList();
  }

  @override
  void initState() {
    print(widget.statMedidas);
    super.initState();
    _initSpots();
  }

  _initSpots() {
    List<FlSpot> spotsSinNormalizar =
        getSpotsFromStatsMedida(widget.statMedidas);
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

    spots = spotsSinNormalizar.map((spot) {
      double x = normalizeTimestamp(spot.x, originalMinX, originalMaxX, 0, 10);
      double y = spot.y;
      return FlSpot(x, y);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double aspectRatio = width > webScreenSize ? 1.70 : 0.75;
    final int totalLabels = spots.length;
    return AspectRatio(
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

    // Evita mostrar la etiqueta si el valor es muy cercano a los extremos desnormalizados
    if (value <=
            minXDesnormalized + marginFactor * (originalMaxX - originalMinX) ||
        value >=
            maxXDesnormalized - marginFactor * (originalMaxX - originalMinX)) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(formattedDate, style: style),
    );
  }

  Widget leftTitleWidgets(
    double value,
    TitleMeta meta,
  ) {
    // return const SizedBox.shrink();
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    return Text('${value.toInt()} ${widget.unit}', style: style);
  }

  double calculateLabelInterval({
    required double chartWidth,
    required int totalLabels,
    required double minX,
    required double maxX,
  }) {
    // Estimar el espacio mínimo en píxeles que debería haber entre etiquetas para evitar el choque
    const double minSpacePerLabel = 60.0;
    // Calcular el número total de intervalos (espacios entre etiquetas) que caben en el ancho del gráfico
    double maxLabelsAllowed = chartWidth / minSpacePerLabel;

    // Calcular el rango total de valores en el eje X después de la normalización
    double normalizedRange = maxX - minX;

    // Calcular el intervalo necesario para ajustarse al número máximo de etiquetas permitidas
    // Dividiendo el rango normalizado entre el número de intervalos (maxLabelsAllowed)
    // Esta parte calcula cuánto "espacio" en términos de valor normalizado debe haber entre cada etiqueta
    double normalizedInterval = normalizedRange / maxLabelsAllowed;

    // Calcular cuántos intervalos de datos cabrían entre etiquetas basado en el intervalo normalizado calculado
    // Redondear hacia arriba para asegurar que no se sobrepongan las etiquetas
    double dataInterval = (totalLabels / normalizedInterval).ceil().toDouble();

    // Asegurarse de que el intervalo es al menos 1 para evitar la división por cero o intervalos negativos
    return max(1, dataInterval);
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
                String text = "${spots[dataIndex].y} ${widget.unit}";
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
        verticalInterval: calculateLabelInterval(
          chartWidth: MediaQuery.of(context).size.width,
          totalLabels: spots.length,
          minX: minX,
          maxX: maxX,
        ),
        horizontalInterval: 5,
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
            interval: calculateLabelInterval(
              chartWidth: MediaQuery.of(context).size.width,
              totalLabels: spots.length,
              minX: minX,
              maxX: maxX,
            ),
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
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
