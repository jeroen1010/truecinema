import 'package:flutter/material.dart';
import 'package:truecinema/theme/app_theme.dart';
import 'package:truecinema/widgets/widgets.dart';
import 'package:truecinema/screens/screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int estadoIndex = 0;

  void itemSeleccionado(int index) {
    setState(() {
      estadoIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BusquedaScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReseniasScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MiListaScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MiPerfilScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = AppTheme.primaryColor;
    const Color backgroundColor = AppTheme.backgroundLight;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TrueCinema'),
          centerTitle: true,
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          elevation: 0,
        ),
        backgroundColor: backgroundColor,
        bottomNavigationBar: tapBar(
          currentIndex: estadoIndex,
          onTap: itemSeleccionado,
          primaryColor: primaryColor,
          backgroundLight: backgroundColor,
          textColor: backgroundColor,
        ),
      ),
    );
  }
}
