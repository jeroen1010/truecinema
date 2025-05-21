import 'package:flutter/material.dart';
import 'package:truecinema/widgets/widgets.dart';
import 'package:truecinema/widgets/user_profile_content.dart';

class MiPerfilScreen extends StatelessWidget {
  const MiPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      estadoIndex: 4,
      title: 'Mi Perfil',
      screen: UserProfileContent(),
    );
  }
}
