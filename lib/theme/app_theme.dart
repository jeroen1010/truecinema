import 'package:flutter/material.dart';

class AppTheme {
  // Paleta salmón
  static const Color primaryColor = Color(0xFFFF6F61);       // Salmón intenso
  static const Color secondaryColor = Color(0xFFFFA07A);     // Salmón claro
  static const Color accentColor = Color(0xFFFA8072);        // Coral / acento
  static const Color backgroundLight = Color(0xFFFFF0EB);    // Fondo claro
  static const Color backgroundDark = Color(0xFF2C1B1B);     // Fondo oscuro
  static const Color accentDark = Color(0xFF8B3A3A);          // Acento oscuro

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        color: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: secondaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: secondaryColor.withOpacity(0.9),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        color: accentDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: accentDark,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white60,
        ),
      ),
      cardTheme: CardTheme(
        color: accentDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Decoración para secciones
  static BoxDecoration get sectionDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Decoración para días u otros elementos
  static BoxDecoration get dayBoxDecoration => BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
