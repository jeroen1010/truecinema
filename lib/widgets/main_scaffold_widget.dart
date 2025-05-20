import 'package:flutter/material.dart';
import 'package:truecinema/theme/app_theme.dart';
import 'package:truecinema/widgets/widgets.dart';
import 'package:truecinema/screens/screens.dart';

class MainScaffold extends StatelessWidget {
  final int estadoIndex;
  final Widget screen;
  final String title;

  const MainScaffold({
    super.key,
    required this.estadoIndex,
    required this.screen,
    required this.title,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == estadoIndex) return;

    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = const HomeScreen();
        break;
      case 1:
        nextScreen = const BusquedaScreen();
        break;
      case 2:
        nextScreen = const ReseniasScreen();
        break;
      case 3:
        nextScreen = const MiListaScreen();
        break;
      case 4:
        nextScreen = const MiPerfilScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.backgroundLight,
        elevation: 0,
      ),
      backgroundColor: AppTheme.backgroundLight,
      body: screen,
      bottomNavigationBar: tapBar(
        currentIndex: estadoIndex,
        onTap: (index) => _onItemTapped(context, index),
        primaryColor: AppTheme.primaryColor,
        backgroundLight: AppTheme.backgroundLight,
        textColor: AppTheme.backgroundLight,
      ),
    );
  }
}
