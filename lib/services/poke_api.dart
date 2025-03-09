import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import '../battle/models/move.dart';

class PokeApi {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  static Future<List<Pokemon>> getPokemons() async {
    final response = await http.get(Uri.parse('$_baseUrl/pokemon?limit=151'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((p) => Pokemon.fromListJson(p)).toList();
    } else {
      throw Exception('Failed to load Pokémon list');
    }
  }

  static Future<Pokemon> getPokemonDetails(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/pokemon/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Pokemon(
        id: data['id'],
        name: data['name'],
        types: (data['types'] as List)
            .map((t) => (t['type']['name'] as String).capitalize())
            .toList(),
        imageUrl: data['sprites']['other']['official-artwork']['front_default'] ?? '',
        stats: (data['stats'] as List).map((s) => Stat(
              name: (s['stat']['name'] as String).capitalize(),
              value: s['base_stat'] as int,
            )).toList(),
        learnableMoves: (data['moves'] as List)
            .map((m) => Move.fromJson(m['move']))
            .toList(),
      );
    }
    throw Exception('Failed to load Pokémon details');
  }
}