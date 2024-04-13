import 'package:fit_match/models/medidas.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartMedidaZoom extends StatefulWidget {
  final List<StatMedida> statMedidas;
  final String unit;
  final String title;

  const ChartMedidaZoom(
      {super.key,
      required this.statMedidas,
      required this.unit,
      required this.title});

  @override
  State<ChartMedidaZoom> createState() => ChartMedidaState();
}

class ChartMedidaState extends State<ChartMedidaZoom> {
  late DateTimeIntervalType intervalType;
  late double interval;
  late ZoomPanBehavior _zoomPanBehavior;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();

    _tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: false,
      enablePanning: true,
      zoomMode: ZoomMode.x,
      enableMouseWheelZooming: true,
    );

    _determineAxisInterval();
  }

  void _determineAxisInterval() {
    if (widget.statMedidas.isEmpty) {
      intervalType = DateTimeIntervalType.months;
      interval = 1;
      return;
    }

    DateTime minDate = widget.statMedidas.first.date;
    DateTime maxDate = widget.statMedidas.first.date;
    for (var data in widget.statMedidas) {
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
        primaryYAxis: NumericAxis(
            labelFormat: '{value}${widget.unit}',
            numberFormat: NumberFormat.decimalPattern(),
            interactiveTooltip: const InteractiveTooltip(enable: false)),
        zoomPanBehavior: _zoomPanBehavior,
        tooltipBehavior: _tooltipBehavior,
        series: <CartesianSeries<StatMedida, DateTime>>[
          LineSeries<StatMedida, DateTime>(
            dataSource: widget.statMedidas,
            xValueMapper: (StatMedida data, _) => data.date,
            yValueMapper: (StatMedida data, _) => data.value,
            name: widget.title,
            color: Theme.of(context).colorScheme.primary, // Color de la línea
            markerSettings: const MarkerSettings(
                isVisible: true), // Muestra los puntos en la serie

            dataLabelSettings: const DataLabelSettings(isVisible: false),

            // onPointTap: (ChartPointDetails details) {
            //   final int pointIndex = details.pointIndex!;
            //   // Custom Tooltip content
            //   final RegistroSet registro = widget.registroSet[pointIndex];
            //   final String tooltipText = _buildTooltipText(registro);
            //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //     content: Text(tooltipText),
            //   ));
            // }
          ),
        ],
      ),
    );
  }
}
