import 'dart:async';

import 'package:fit_match/models/logs.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/services/logs_service.dart';
import 'package:fit_match/widget/search_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class LogsScreen extends StatefulWidget {
  final User user;
  const LogsScreen({super.key, required this.user});
  @override
  State<StatefulWidget> createState() {
    return LogsScreenState();
  }
}

class LogsScreenState extends State<LogsScreen>
    with SingleTickerProviderStateMixin {
  List<Log> logs = [];
  List<Bloqueo> bloqueos = [];

  bool isLoading = false;
  late TabController _tabController;

  String filtroBusqueda = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    initLogs();
  }

  void _onSearchChanged(String? text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        filtroBusqueda = text ?? '';
      });

      initLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Plantillas de entrenamiento'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 50),
          child: Column(children: [
            SearchWidget(
              text: filtroBusqueda,
              hintText: 'Filtrar por Ip',
              onChanged: (text) => _onSearchChanged(text),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Registros'),
                Tab(text: 'Ips bloqueadas'),
              ],
            ),
          ]),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProgramList(context, 'logs'),
            _buildProgramList(context, 'block'),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramList(
    BuildContext context,
    String tipo,
  ) {
    List<Registro> lista = tipo == 'logs' ? logs : bloqueos;

    Widget liswViewWithListItem = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        ...lista.map((template) => _buildListItem(template, tipo)).toList(),
      ],
    );
    return kIsWeb
        ? liswViewWithListItem
        : LiquidPullToRefresh(
            onRefresh: initLogs,
            color: Theme.of(context).colorScheme.primary,
            child: liswViewWithListItem);
  }

  Widget _buildListItem(
    Registro registro,
    String tipo,
  ) {
    if (tipo == 'logs') {
      Log log = registro as Log;
      return Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: ListTile(
          leading: Icon(log.exito == true ? Icons.check_circle : Icons.error,
              color: log.exito == true ? Colors.green : Colors.red),
          title: Text(
            "IP: ${log.ipAddress}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(log.fecha)}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                "Email: ${log.email}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                "Resultado: ${log.exito ? 'Exitoso' : 'Fallido'}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (tipo == 'block') {
      Bloqueo bloqueo = registro as Bloqueo;
      return Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: ListTile(
          leading: const Icon(Icons.block, color: Colors.red),
          title: Text(
            "IP Bloqueada: ${bloqueo.ipAddress}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bloqueo desde: ${DateFormat('dd/MM/yyyy HH:mm').format(bloqueo.timestamp)}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                "Bloqueo hasta: ${DateFormat('dd/MM/yyyy HH:mm').format(bloqueo.fechaHasta)}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> initLogs() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Log> logs = await LogsMethods().getLogs(widget.user.user_id as int,
          ip: filtroBusqueda != '' ? filtroBusqueda : null);

      List<Bloqueo> bloqueos = await LogsMethods().getBloqueos(
          widget.user.user_id as int,
          ip: filtroBusqueda != '' ? filtroBusqueda : null);
      if (mounted) {
        setState(() {
          this.logs = logs;
          this.bloqueos = bloqueos;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
