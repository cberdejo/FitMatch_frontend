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

  @override
  void initState() {
    super.initState();
    initUsers();
  }

  @override
  Widget build(BuildContext context) {
    Widget listaUsers = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: usuarios.length,
        separatorBuilder: (context, index) =>
            Divider(color: Theme.of(context).colorScheme.onBackground),
        itemBuilder: (context, index) {
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
                // const Text("Biografía: ",
                //     style:
                //         TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                // ExpandableText(text: usuario.bio ?? ""),
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
        });

    Widget usersBody() {
      if (kIsWeb) {
        // Si es web, retorna solo la lista
        return listaUsers;
      } else {
        // Si no es web, usa LiquidPullToRefresh
        return LiquidPullToRefresh(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async {
            await initUsers();
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : usersBody());
  }

  Widget buildFilters() {
    return Column(children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 16.0,
        children: [
          DropdownButton<String>(
            value: selectedRole,
            onChanged: (value) {
              setState(() {
                selectedRole = value!;
              });
              initUsers();
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
          });
          initUsers(); // Actualizar lista con el nuevo valor del filtro
        },
      ),
    ]);
  }

  Future<void> initUsers() async {
    try {
      List<User> fetchedUsers =
          await UserMethods().getAllUsers(widget.user.user_id as int);
      // Filtrar por nombre de usuario o correo electrónico
      if (filterValue.isNotEmpty) {
        fetchedUsers = fetchedUsers.where((user) {
          if (selectedFilterType == 'Nombre de usuario') {
            return user.username
                .toLowerCase()
                .contains(filterValue.toLowerCase());
          } else {
            return user.email.toLowerCase().contains(filterValue.toLowerCase());
          }
        }).toList();
      }
      // Filtrar por rol
      if (selectedRole != 'Todos') {
        fetchedUsers = fetchedUsers.where((user) {
          return (selectedRole == 'Administrador' &&
                  user.profile_id == adminId) ||
              (selectedRole == 'Cliente' && user.profile_id == clientId);
        }).toList();
      }
      setState(() => usuarios = fetchedUsers);
    } catch (e) {
      print(e);
    }
  }

  Future<void> banUnbanUser(int userId, int banUserId) async {
    try {
      UserMethods().banUser(userId, banUserId);
    } catch (e) {
      print(e);
    }
  }
}
