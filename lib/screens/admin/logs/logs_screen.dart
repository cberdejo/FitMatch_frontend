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
  int _currentPage = 1;
  bool _hasMore = true;
  final int _pageSize = 100;

  String filtroBusqueda = '';
  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _scrollController.addListener(_loadMoreOnScroll);
    initLogs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String? text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        filtroBusqueda = text ?? '';
      });

      initLogs(isRefresh: true);
    });
  }

  void _loadMoreOnScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        _hasMore) {
      initLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Plantillas de entrenamiento'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 50),
          child: Column(
            children: [
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
            ],
          ),
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

  Widget _buildProgramList(BuildContext context, String tipo) {
    List<Registro> lista = tipo == 'logs' ? logs : bloqueos;

    Widget listViewWithListItem = ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: lista.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == lista.length) {
          return _hasMore
              ? const Center(child: CircularProgressIndicator())
              : const Center(child: Text("Estás al día"));
        }
        return _buildListItem(lista[index], tipo);
      },
      controller: _scrollController,
    );

    return kIsWeb
        ? listViewWithListItem
        : LiquidPullToRefresh(
            onRefresh: () async {
              await initLogs(isRefresh: true);
            },
            color: Theme.of(context).colorScheme.primary,
            child: listViewWithListItem,
          );
  }

  Widget _buildListItem(Registro registro, String tipo) {
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

  Future<void> initLogs({bool isRefresh = false}) async {
    if (isLoading) return;
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        logs.clear();
        bloqueos.clear();
      });
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<Log> fetchedLogs = await LogsMethods().getLogs(
        widget.user.user_id as int,
        page: _currentPage,
        pageSize: _pageSize,
        ip: filtroBusqueda.isNotEmpty ? filtroBusqueda : null,
      );

      List<Bloqueo> fetchedBloqueos = await LogsMethods().getBloqueos(
        widget.user.user_id as int,
        page: _currentPage,
        pageSize: _pageSize,
        ip: filtroBusqueda.isNotEmpty ? filtroBusqueda : null,
      );

      if (mounted) {
        setState(() {
          if (fetchedLogs.isNotEmpty || fetchedBloqueos.isNotEmpty) {
            _currentPage++;
            logs.addAll(fetchedLogs);
            bloqueos.addAll(fetchedBloqueos);
            if (fetchedLogs.length < _pageSize &&
                fetchedBloqueos.length < _pageSize) {
              _hasMore = false;
            }
          } else {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          _hasMore = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
