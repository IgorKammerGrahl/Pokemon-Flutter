import 'pokemon.dart';

class Team {
  final String id;
  String name;
  List<Pokemon> pokemons;

  Team({
    required this.id,
    required this.name,
    required this.pokemons,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      pokemons: (json['pokemons'] as List).map((p) => Pokemon.fromJson(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pokemons': pokemons.map((p) => p.toJson()).toList(),
    };
  }
}