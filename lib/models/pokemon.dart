import 'dart:core';
import '../battle/models/move.dart';


class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final String imageUrl;
  List<Stat> stats;
  List<Move> learnableMoves;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.imageUrl,
    required this.stats,
    required this.learnableMoves,
  });

  Pokemon copyWith({
    List<Stat>? stats,
    List<Move>? learnableMoves,
  }) {
    return Pokemon(
      id: id,
      name: name,
      types: types,
      imageUrl: imageUrl,
      stats: stats ?? this.stats,
      learnableMoves: learnableMoves ?? this.learnableMoves,
    );
  }

    Pokemon.empty()
      : id = 0,
        name = 'Unknown',
        types = const [],
        imageUrl = '',
        stats = const [],
        learnableMoves = const [];

  factory Pokemon.fromListJson(Map<String, dynamic> json) {
  final url = json['url'] as String;
  final parts = url.split('/');
  final id = int.parse(parts[parts.length - 2]);
  
  return Pokemon(
    id: id,
    name: (json['name'] as String).capitalize(),
    types: [],
    imageUrl: '',
    stats: [],
    learnableMoves: [],
  );
}

  factory Pokemon.fromJson(Map<String, dynamic> json) {
  return Pokemon(
    id: json['id'] as int,
    name: json['name'] as String,
    types: (json['types'] as List).map((t) => t as String).toList(),
    imageUrl: json['imageUrl'] as String,
    stats: (json['stats'] as List)
        .map((s) => Stat.fromJson(s as Map<String, dynamic>))
        .toList(),
    learnableMoves: (json['learnableMoves'] as List)
        .map((m) => Move.fromJson(m as Map<String, dynamic>))
        .toList(),
  );
}


  factory Pokemon.fromDetailJson(Map<String, dynamic> json) {
  return Pokemon(
    id: json['id'] as int? ?? 0,
    name: (json['name'] as String?)?.capitalize() ?? 'Unknown',
    types: _parseTypes(json['types']),
    imageUrl: _parseImageUrl(json),
    stats: _parseStats(json['stats']),
    learnableMoves: _parseMoves(json['moves']),
  );
}

  

  static List<String> _parseTypes(dynamic types) {
  return (types as List?)?.map((t) => 
    (t['type']['name'] as String?)?.capitalize() ?? 'Normal'
  ).toList() ?? [];
}

  static String _parseImageUrl(Map<String, dynamic> json) {
  return json['sprites']?['other']?['official-artwork']?['front_default'] as String? ?? 
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/0.png';
}

  static List<Stat> _parseStats(dynamic stats) {
  return (stats as List?)?.map((s) => Stat(
    name: (s['stat']['name'] as String?)?.capitalize() ?? 'hp',
    value: s['base_stat'] as int? ?? 0
  )).toList() ?? [];
}

  static List<Move> _parseMoves(dynamic moves) {
  return (moves as List?)?.map((move) => 
    Move.fromJson(move['move'] ?? {})
  ).toList() ?? [];
}

  @override
  bool operator ==(Object other) => identical(this, other) || other is Pokemon && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'types': types,
    'imageUrl': imageUrl,
    'stats': stats.map((s) => s.toJson()).toList(),
    'learnableMoves': learnableMoves.map((m) => m.toJson()).toList(),
  };
}

class Stat {
  final String name;
  final int value;

  const Stat({required this.name, required this.value});

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      name: json['name'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
  };
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}