import 'dart:async';

import 'package:fit_match/models/user.dart';
import 'package:fit_match/services/auth_service.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/search_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ManageUserScreen extends StatefulWidget {
  final User user;
  const ManageUserScreen({super.key, required this.user});
  @override
  State<StatefulWidget> createState() {
    return ManageUserScreenState();
  }
}

class ManageUserScreenState extends State<ManageUserScreen>
    with SingleTickerProviderStateMixin {
  List<User> usuarios = [];
  Timer? _debounce;

  String selectedFilterType = 'Nombre de usuario'; // O 'Correo electrónico'
  String filterValue = '';
  String selectedRole = 'Todos'; // O 'Usuario', 'Administrador'

  bool isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _pageSize = 5;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreOnScroll);
    initUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreOnScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        _hasMore) {
      initUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget listaUsers = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: usuarios.length + (_hasMore ? 1 : 0),
      separatorBuilder: (context, index) =>
          Divider(color: Theme.of(context).colorScheme.onBackground),
      itemBuilder: (context, index) {
        if (index == usuarios.length) {
          return _hasMore
              ? const Center(child: CircularProgressIndicator())
              : const Center(child: Text("Estás al día"));
        }
        var usuario = usuarios[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: usuario.profile_picture != null
                ? NetworkImage(usuario.profile_picture!)
                : null,
            child: usuario.profile_picture == null
                ? const Icon(Icons.account_circle, size: 40)
                : null,
          ),
          title: Text(
            usuario.username,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuario.email,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Rol: ${usuario.profile_id == adminId ? 'Administrador' : 'Cliente'}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Baneado: ${usuario.banned ? 'Si' : 'No'}',
                style: TextStyle(
                    color: usuario.banned ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing: usuario.profile_id != adminId
              ? IconButton(
                  icon: Icon(
                    usuario.banned ? Icons.remove_circle : Icons.block,
                    color: usuario.banned ? Colors.green : Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      usuario.banned = !usuario.banned;
                    });
                    banUnbanUser(
                        widget.user.user_id as int, usuario.user_id as int);
                  },
                )
              : null,
        );
      },
      controller: _scrollController,
    );

    Widget usersBody() {
      if (kIsWeb) {
        return listaUsers;
      } else {
        return LiquidPullToRefresh(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async {
            await initUsers(isRefresh: true);
          },
          child: listaUsers,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar usuarios"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 50),
          child: buildFilters(),
        ),
      ),
      body: usuarios.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No hay Usuarios",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : usersBody(),
    );
  }

  Widget buildFilters() {
    return Column(children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 16.0,
        children: [
          DropdownButton<String>(
            value: selectedRole,
            iconEnabledColor: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            dropdownColor: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.background,
            focusColor: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.background,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
            onChanged: (value) {
              setState(() {
                selectedRole = value!;
                initUsers(isRefresh: true);
              });
            },
            items: ['Todos', 'Cliente', 'Administrador']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          DropdownButton<String>(
            value: selectedFilterType,
            iconEnabledColor: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            dropdownColor: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.background,
            focusColor: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.background,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
            onChanged: (value) {
              setState(() {
                selectedFilterType = value!;
                filterValue = ''; // Limpiar el valor del filtro anterior
              });
            },
            items: ['Nombre de usuario', 'Correo electrónico']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      SearchWidget(
        text: filterValue,
        hintText: 'Filtrar por $selectedFilterType',
        onChanged: (value) {
          setState(() {
            filterValue = value;
            initUsers(isRefresh: true);
          });
        },
      ),
    ]);
  }

  Future<void> initUsers({bool isRefresh = false}) async {
    if (isLoading) return;
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        usuarios.clear();
      });
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<User> fetchedUsers = await UserMethods().getAllUsers(
        widget.user.user_id as int,
        page: _currentPage,
        pageSize: _pageSize,
        filterType: selectedFilterType != 'Todos' ? selectedFilterType : null,
        filterValue: filterValue.isNotEmpty ? filterValue : null,
        role: selectedRole != 'Todos' ? selectedRole : null,
      );

      setState(() {
        if (fetchedUsers.isNotEmpty) {
          _currentPage++;
          usuarios.addAll(fetchedUsers);
          if (fetchedUsers.length < _pageSize) {
            _hasMore = false;
          }
        } else {
          _hasMore = false;
        }
      });
    } catch (e) {
      print(e);
      setState(() {
        _hasMore = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> banUnbanUser(int userId, int banUserId) async {
    try {
      await UserMethods().banUser(userId, banUserId);
      initUsers(isRefresh: true); // Actualizar la lista después de ban/unban
    } catch (e) {
      print(e);
    }
  }
}
