import 'package:flutter/material.dart';
import 'package:truecinema/widgets/widgets.dart';

class BusquedaScreen extends StatelessWidget {
  const BusquedaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      estadoIndex: 1,
      title: 'Buscar',
      screen: Center(
        child: Text(
          'Pantalla de Búsqueda',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
