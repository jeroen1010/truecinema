import 'package:flutter/material.dart';
import 'package:truecinema/widgets/widgets.dart';

class ReseniasScreen extends StatelessWidget {
  const ReseniasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      estadoIndex: 2,
      title: 'Reseñas',
      screen: Center(
        child: Text(
          'Pantalla de Reseñas',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
