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

  List<FlSpot> getSpotsFromRegistros(
      List<RegistroSet> registros, int registerTypeId) {
    return registros.asMap().entries.map((entry) {
      // int index = entry.key;
      double value = 0.0; // Inicialización predeterminada

      double date = entry.value.timestamp.millisecondsSinceEpoch.toDouble();

      switch (registerTypeId) {
        case 4: // AMRAP: usar 'reps'
          value = 1;
          break;
        case 5: // Tiempo
          value = entry.value.time ?? 0.0;
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
    }).toList();
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
    const dayInMilliseconds = 86400000;
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onBackground,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    // Asegúrate de que los valores de originalMinX y originalMaxX sean válidos
    if (originalMinX.isNaN ||
        originalMaxX.isNaN ||
        originalMaxX <= originalMinX) {
      // Considera retornar un widget vacío o con valores predeterminados si los rangos no son válidos
      return const SizedBox.shrink();
    }

    // Desnormaliza el valor para convertirlo de vuelta a un timestamp
    double desnormalizedValue =
        desnormalizeValue(value, originalMinX, originalMaxX, 0, 10);

    // Asegúrate de que desnormalizedValue sea un valor válido
    if (desnormalizedValue.isNaN) {
      // Manejo del caso en que desnormalizedValue es NaN
      return const SizedBox.shrink();
    }

    // Ajusta el formato de fecha basado en el rango visible
    String dateFormat;
    double visibleRange = originalMaxX - originalMinX;
    if (visibleRange > 777600000) {
      // Más de 9 días
      dateFormat = "MMM yy";
    } else {
      // 2 días o menos
      dateFormat = "MMM d";
    }

    // Convierte el valor desnormalizado de timestamp a fecha
    var date = DateTime.fromMillisecondsSinceEpoch(desnormalizedValue.toInt());
    var formattedDate = DateFormat(dateFormat).format(date);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(formattedDate, style: style),
    );
  }

  // double calculateBottomInterval() {
  //   final double totalRange = originalMaxX - originalMinX;

  //   const double minVisibleInterval = 86400000; // 1 día en milisegundos.

  //   // Calcula el número de intervalos visibles basado en el ancho del gráfico y un ancho estimado por etiqueta.
  //   // Ajusta el 'labelWidth' según el tamaño medio de tus etiquetas para evitar el solapamiento.
  //   double width = MediaQuery.of(context).size.width -
  //       40; // Ajusta según el padding/margen de tu gráfico.
  //   const double labelWidth = 60; // Estimación del ancho por etiqueta.
  //   int numLabels = (width / labelWidth).floor();

  //   // Asegúrate de no dividir por cero.
  //   if (numLabels == 0) {
  //     return totalRange; // Solo muestra una etiqueta si no hay suficiente espacio.
  //   }

  //   // Calcula el intervalo de tiempo (en milisegundos) entre etiquetas para evitar el solapamiento.
  //   double interval = totalRange / numLabels;

  //   // Asegura que el intervalo no sea menor que el mínimo establecido.
  //   interval = max(interval, minVisibleInterval);

  //   // Convierte el intervalo de milisegundos a la unidad que estés usando en el eje X.
  //   // Si estás normalizando las fechas a otro rango (por ejemplo, 0 a 10), necesitarás convertir este intervalo.
  //   // De lo contrario, si estás usando milisegundos directamente, puedes devolver este valor.
  //   return normalizeTimestamp(interval, originalMinX, originalMaxX, 0, 10) -
  //       normalizeTimestamp(0, originalMinX, originalMaxX, 0, 10);
  // }

  double calculateBottomInterval() {
    // Verifica si originalMinX o originalMaxX no son números válidos o si son iguales.
    if (originalMinX.isNaN ||
        originalMaxX.isNaN ||
        originalMaxX == originalMinX) {
      // Retorna un valor predeterminado seguro para evitar división por cero o operaciones con NaN.
      return 86400000; // Equivalente a 1 día en milisegundos como valor predeterminado.
    }

    final double totalRange = originalMaxX - originalMinX;
    const double minVisibleInterval = 86400000; // 1 día en milisegundos.

    // Calcula el ancho disponible para el gráfico, ajustando por el padding/margen.
    double width = MediaQuery.of(context).size.width - 40;
    const double labelWidth =
        60; // Estimación del ancho necesario por etiqueta.

    // Calcula el número de etiquetas que pueden ajustarse sin solaparse.
    int numLabels = (width / labelWidth).floor();

    // Si numLabels es 0, ajusta a 1 para evitar la división por cero más adelante.
    numLabels = max(numLabels, 1);

    // Calcula el intervalo de tiempo entre etiquetas para evitar el solapamiento.
    double interval = totalRange / numLabels;

    // Asegura que el intervalo no sea menor que el mínimo visible establecido.
    interval = max(interval, minVisibleInterval);

    // La función normalizeTimestamp() ajusta el intervalo calculado a la escala utilizada en el eje X.
    // Es necesario asegurarse de que esta función maneje correctamente los valores y no genere NaN.
    double normalizedInterval =
        normalizeTimestamp(interval, originalMinX, originalMaxX, 0, 10);
    double normalizedZero =
        normalizeTimestamp(0, originalMinX, originalMaxX, 0, 10);

    // Verifica si el resultado de la normalización es NaN.
    if (normalizedInterval.isNaN || normalizedZero.isNaN) {
      // Retorna un valor predeterminado si la normalización falla.
      return 86400000; // Equivalente a 1 día en milisegundos como valor predeterminado.
    }

    return normalizedInterval - normalizedZero;
  }

  Widget leftTitleWidgets(
    double value,
    TitleMeta meta,
  ) {
    return const SizedBox.shrink();
    // const style = TextStyle(
    //   color: Color(0xff67727d),
    //   fontWeight: FontWeight.bold,
    //   fontSize: 15,
    // );

    // double interval;
    // if (originalMaxY != originalMinY) {
    //   interval = (originalMaxY - originalMinY) / 5;
    // } else {
    //   interval = 1;
    // }
    // double roundedValue = (value / interval).round() * interval;
    // if (value % interval == 0 ||
    //     value == originalMinY ||
    //     value == originalMaxY) {
    //   return Text(roundedValue.toInt().toString(), style: style);
    // } else {
    //   // Retorna un widget vacío para los valores que no coincidan
    //   return const SizedBox.shrink();
    // }
  }

  LineChartData mainData(double aspectRatio, int totalLabels) {
    const double marginFactor = 0.00; // El margen es el 5% del rango total

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
    double visibleRange =
        originalMaxX - originalMinX; // Actualiza esto según el zoom

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
                String text =
                    "${data.reps} repes x  ${widget.system == 'metrico' ? data.weight : fromKgToLbs(data.weight ?? 0.0)} $system";
                switch (widget.registerTypeId) {
                  case 4: // AMRAP: usar 'reps'
                    text = "Armrap";
                    break;
                  case 5: // Tiempo
                    text = "${data.time} minutos";
                    break;
                  case 6: // rango Tiempoç

                    text =
                        "${data.time} minutos x ${widget.system == 'metrico' ? data.weight : fromKgToLbs(data.weight ?? 0.0)} $system";

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
        horizontalInterval: 1,
        verticalInterval: 1,
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
            interval: calculateBottomInterval(),
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
          dotData: const FlDotData(
            show: false,
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
