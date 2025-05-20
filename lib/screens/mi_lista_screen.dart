import 'package:flutter/material.dart';
import 'package:truecinema/widgets/widgets.dart';

class MiListaScreen extends StatelessWidget {
  const MiListaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      estadoIndex: 3,
      title: 'Mi Lista',
      screen: Center(
        child: Text(
          'Pantalla de Mi Lista',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
