import 'package:flutter/material.dart'; 

class AppColors {
  // Cores primárias
  static const primary = Color(0xFFEF5350);
  static const background = Color(0xFFF5F5F5);

  // Cores por tipo (sem null assertion)
  static Map<String, Color> typeColors = {
    'fire': const Color(0xFFF08030),
    'water': const Color(0xFF6890F0),
    'grass': const Color(0xFF78C850),
    'electric': const Color(0xFFF8D030),
    'psychic': const Color(0xFFF85888),
    'ice': const Color(0xFF98D8D8),
    'dragon': const Color(0xFF7038F8),
    'dark': const Color(0xFF705848),
    'fairy': const Color(0xFFEE99AC),
    'normal': const Color(0xFFA8A878),
    'fighting': const Color(0xFFC03028),
    'flying': const Color(0xFFA890F0),
    'poison': const Color(0xFFA040A0),
    'ground': const Color(0xFFE0C068),
    'rock': const Color(0xFFB8A038),
    'bug': const Color(0xFFA8B820),
    'ghost': const Color(0xFF705898),
    'steel': const Color(0xFFB8B8D0),
  };

  static Color getTypeColor(String type) {
    return typeColors[type.toLowerCase()] ?? Colors.grey; // Fallback
  }

  
}


class AppTextStyles {
  static const pokemonTitle = TextStyle(
    fontFamily: 'Pokemon',
    fontSize: 24,
    color: Colors.black,
  );
}

class ApiEndpoints {
  static const pokemonList = 'https://pokeapi.co/api/v2/pokemon';
}

