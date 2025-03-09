import 'pokemon.dart';
import '../battle/models/battle_pokemon.dart';

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
      id: json['id'] as String,
      name: json['name'] as String,
      pokemons: (json['pokemons'] as List<dynamic>)
          .map((p) => Pokemon.fromJson(p as Map<String, dynamic>))
          .toList(),
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

class BattleTeam {
  final List<BattlePokemon> pokemons;
  int currentIndex;

  BattleTeam({
    required this.pokemons,
    this.currentIndex = 0,
  }) : assert(pokemons.isNotEmpty, 'Team must have at least 1 Pokémon');

  BattlePokemon get currentPokemon => pokemons[currentIndex];
  
  bool get canSwitch => pokemons.length > 1;
  
  void switchPokemon(int newIndex) {
    assert(newIndex >= 0 && newIndex < pokemons.length);
    currentIndex = newIndex;
  }
}