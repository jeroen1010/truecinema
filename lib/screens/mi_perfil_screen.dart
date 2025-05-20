import 'package:flutter/material.dart';
import 'package:truecinema/theme/app_theme.dart';
import 'package:truecinema/widgets/widgets.dart';

class MiPerfilScreen extends StatelessWidget {
  const MiPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      estadoIndex: 4,
      title: 'Mi Perfil',
      screen: Center(
        child: Text('Esta es la pantalla de Mi Perfil'),
      ),
    );
  }
}
