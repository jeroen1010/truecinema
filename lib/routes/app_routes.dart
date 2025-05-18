import 'package:flutter/material.dart';
import '../screens/screens.dart';
import '../models/models.dart';

class AppRoutes {
  static const String initialRoute = 'user';

  static final List<MenuOption> menuOptions = [
    MenuOption(
        route: 'home',
        name: 'Home',
        screen: const HomeScreen(),
        icon: Icons.home),
    MenuOption(
        route: 'user',
        name: 'Usuarios',
        screen: const UsuariosScreen(),
        icon: Icons.people),
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};

    for (final option in menuOptions) {
      appRoutes.addAll({option.route: (BuildContext context) => option.screen});
    }

    return appRoutes;
  }

}
