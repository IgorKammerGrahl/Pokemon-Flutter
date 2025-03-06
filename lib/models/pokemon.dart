import 'dart:core';
import '../extensions/string_extensions.dart';

class Pokemon {
  final String name;
  final int id;
  final List<String> types;
  final String imageUrl;
  final List<Stat> stats;

  Pokemon({
    required this.name,
    required this.id,
    required this.types,
    required this.imageUrl,
    required this.stats,
  });

  // Para a lista inicial (apenas nome e URL)
  factory Pokemon.fromListJson(Map<String, dynamic> json) {
    return Pokemon(
      name: (json['name'] as String).capitalize(),
      id: _extractIdFromUrl(json['url'] as String),
      types: [],
      imageUrl: '',
      stats: [],
    );
  }

  // Para os detalhes completos
  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
    return Pokemon(
      name: (json['name'] as String).capitalize(),
      id: json['id'] as int,
      types: (json['types'] as List).map((t) => 
        (t['type']['name'] as String).capitalize()
      ).toList(),
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] as String,
      stats: (json['stats'] as List).map((s) => 
        Stat(
          name: (s['stat']['name'] as String).capitalize(),
          value: s['base_stat'] as int
        )
      ).toList(),
    );
  }
  

  // Método de extração de ID
  static int _extractIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      return int.parse(segments.lastWhere((s) => s.isNotEmpty));
    } catch (e) {
      print('‼️ Erro ao extrair ID da URL: $url | $e');
      return 0;
    }
  }

  // Serialização para SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types,
      'imageUrl': imageUrl,
      'stats': stats.map((s) => s.toJson()).toList(),
    };
  }

  // Desserialização do JSON salvo
  factory Pokemon.fromJson(Map<String, dynamic> json) {
  return Pokemon(
    id: json['id'] as int,
    name: json['name'] as String,
    types: (json['types'] as List).cast<String>(),
    imageUrl: json['imageUrl'] as String,
    stats: (json['stats'] as List)
        .map((s) => Stat.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}
}

class Stat {
  final String name;
  final int value;

  const Stat({required this.name, required this.value});

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
  };

  factory Stat.fromJson(Map<String, dynamic> json) => Stat(
    name: json['name'] as String,
    value: json['value'] as int,
  );
}