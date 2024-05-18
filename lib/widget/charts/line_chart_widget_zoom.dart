import 'package:fit_match/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fit_match/models/registros.dart';

class LineChartZoom extends StatefulWidget {
  final List<RegistroSet> registroSet;
  final int registerTypeId;
  final String system;

  const LineChartZoom(
      {Key? key,
      required this.registroSet,
      required this.registerTypeId,
      required this.system})
      : super(key: key);

  @override
  LineChartZoomState createState() => LineChartZoomState();
}

class LineChartZoomState extends State<LineChartZoom> {
  late List<_ChartData> chartData;
  late List<RegistroSet> filteredRegistroSet;
  late DateTimeIntervalType intervalType;
  late double interval;
  late ZoomPanBehavior _zoomPanBehavior;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    chartData = getChartData();
    filteredRegistroSet = getFilteredRegistroSet();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      builder: (context, dynamic data, dynamic point, int pointIndex,
          int seriesIndex) {
        final RegistroSet registro = filteredRegistroSet[pointIndex];
        final String tooltipText = _buildTooltipText(registro);
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            tooltipText,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
      enableMouseWheelZooming: true,
    );

    _determineAxisInterval();
  }

  void _determineAxisInterval() {
    if (chartData.isEmpty) {
      intervalType = DateTimeIntervalType.months;
      interval = 1;
      return;
    }

    DateTime minDate = chartData.first.date;
    DateTime maxDate = chartData.first.date;
    for (var data in chartData) {
      if (data.date.isBefore(minDate)) minDate = data.date;
      if (data.date.isAfter(maxDate)) maxDate = data.date;
    }

    if (minDate.year == maxDate.year && minDate.month == maxDate.month) {
      intervalType = DateTimeIntervalType.days;
      interval = 1;
    } else {
      intervalType = DateTimeIntervalType.months;
      interval = 1;
    }
  }

  List<_ChartData> getChartData() {
    return widget.registroSet
        .map((registro) {
          double value = 0.0;
          switch (widget.registerTypeId) {
            case 4: // AMRAP: usar 'reps'
              value = registro.reps?.toDouble() ?? 0.0;
              break;
            case 5: // Tiempo
              value = registro.time?.toDouble() ?? 0.0;
              break;
            case 6: // Rango Tiempo
              value = (registro.time?.toDouble() ?? 0.0) *
                  (registro.weight?.toDouble() ?? 0.0);
              break;
            default: // Otro tipo: usar 'weight'
              value = registro.weight?.toDouble() ?? 0.0;
              break;
          }
          return _ChartData(registro.timestamp, value);
        })
        .where((spot) => spot.value > 0)
        .toList();
  }

  List<RegistroSet> getFilteredRegistroSet() {
    return widget.registroSet.where((registro) {
      double value = 0.0;
      switch (widget.registerTypeId) {
        case 4: // AMRAP: usar 'reps'
          value = registro.reps?.toDouble() ?? 0.0;
          break;
        case 5: // Tiempo
          value = registro.time?.toDouble() ?? 0.0;
          break;
        case 6: // Rango Tiempo
          value = (registro.time?.toDouble() ?? 0.0) *
              (registro.weight?.toDouble() ?? 0.0);
          break;
        default: // Otro tipo: usar 'weight'
          value = registro.weight?.toDouble() ?? 0.0;
          break;
      }
      return value > 0;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCartesianChart(
        primaryXAxis: DateTimeAxis(
          dateFormat: intervalType == DateTimeIntervalType.months
              ? DateFormat.yMMM()
              : DateFormat.MMMd(),
          intervalType: intervalType,
          interval: interval,
        ),
        primaryYAxis: const NumericAxis(
          isVisible: true,
          labelStyle: TextStyle(
            color: Colors.transparent,
          ),
        ),
        zoomPanBehavior: _zoomPanBehavior,
        tooltipBehavior: _tooltipBehavior,
        series: <CartesianSeries<_ChartData, DateTime>>[
          LineSeries<_ChartData, DateTime>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.date,
            yValueMapper: (_ChartData data, _) => data.value,
            name: 'Registro',
            color: Theme.of(context).colorScheme.primary, // Color de la línea
            markerSettings: const MarkerSettings(
                isVisible: true), // Muestra los puntos en la serie

            dataLabelSettings: const DataLabelSettings(
              isVisible: false,
            ),
          ),
        ],
      ),
    );
  }

  String _buildTooltipText(RegistroSet data) {
    final num weightValue = data.weight ?? 0.0;
    final String weightText;

    if (widget.system == 'metrico') {
      weightText = weightValue.toStringAsFixed(1);
    } else {
      double lbs = fromKgToLbs(weightValue);
      weightText = lbs.toStringAsFixed(1);
    }

    final String system = widget.system == 'metrico' ? 'kg' : 'lbs';
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
    return text;
  }
}

class _ChartData {
  final DateTime date;
  final double value;

  _ChartData(this.date, this.value);
}
