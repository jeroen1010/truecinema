import 'package:flutter/material.dart';
import 'package:truecinema/theme/app_theme.dart';
import 'package:truecinema/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      estadoIndex: 0,
      title: 'TrueCinema',
      screen: HomeContent(),
    );
  }
}
