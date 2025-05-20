import 'package:flutter/material.dart';
import 'package:truecinema/screens/login_screen.dart';
import 'package:truecinema/screens/registro_screen.dart';
import '../screens/screens.dart';
import '../models/models.dart';

class AppRoutes {
  static const String initialRoute = 'home';

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
    MenuOption(
        route: 'login',
        name: 'Login',
        screen: const LoginScreen(),
        icon: Icons.login),
    MenuOption(
        route: 'registro',
        name: 'Registro',
        screen: const RegistroScreen(),
        icon: Icons.person_add),
    MenuOption(
        route: 'perfil',
        name: 'perfil',
        screen: const MiPerfilScreen(),
        icon: Icons.person_3_outlined),
    MenuOption(
        route: 'lista',
        name: 'lista',
        screen: const MiListaScreen(),
        icon: Icons.star),
    MenuOption(
        route: 'resenia',
        name: 'resenia',
        screen: const ReseniasScreen(),
        icon: Icons.chat_bubble),
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};

    for (final option in menuOptions) {
      appRoutes.addAll({option.route: (BuildContext context) => option.screen});
    }

    return appRoutes;
  }

}
