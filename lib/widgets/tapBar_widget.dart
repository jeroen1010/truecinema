import 'package:flutter/material.dart';

BottomNavigationBar tapBar({
  required int currentIndex,
  required Function(int) onTap,
  required Color primaryColor,
  required Color backgroundLight,
  required Color textColor,
}) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onTap,
    backgroundColor: primaryColor,
    selectedItemColor: backgroundLight,
    unselectedItemColor: textColor.withOpacity(0.7),
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Buscar',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        label: 'Reseñas',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.star),
        label: 'Mi Lista',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ],
  );
}
