import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';
import '../battle/models/move.dart';
import 'shared_preferences_extensions.dart';

class PokeApi {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  static const _cacheDuration = Duration(hours: 24);

  static Future<List<Pokemon>> getPokemons() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('pokemon_list');
    
    if (cachedData != null) {
      final cacheDate = prefs.getDateTime('pokemon_list_date');
      if (cacheDate?.add(_cacheDuration).isAfter(DateTime.now()) ?? false) {
        return (json.decode(cachedData) as List).map((p) => Pokemon.fromJson(p)).toList();
      }
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/pokemon?limit=151'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pokemons = (data['results'] as List).map((p) => Pokemon.fromListJson(p)).toList();
        
        // Salvar cache
        await prefs.setString('pokemon_list', json.encode(pokemons));
        await prefs.setDateTime('pokemon_list_date', DateTime.now());
        
        return pokemons;
      }
      throw Exception('Failed to load Pokémon list');
    } catch (e) {
      debugPrint('Erro em getPokemons(): $e');
      return [];
    }
  }

  static Future<Pokemon> getPokemonDetails(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('pokemon_$id');
    
    if (cachedData != null) {
      return Pokemon.fromJson(json.decode(cachedData));
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/pokemon/$id'));
      if (response.statusCode != 200) return Pokemon.empty();

      final data = jsonDecode(response.body);
      final pokemon = Pokemon(
        id: data['id'] as int? ?? 0,
        name: (data['name'] as String?)?.capitalize() ?? 'Unknown',
        types: (data['types'] as List?)?.map((t) => 
          (t['type']['name'] as String?)?.capitalize() ?? 'Normal'
        ).toList() ?? [],
        imageUrl: data['sprites']?['other']?['official-artwork']?['front_default'] as String? ?? '',
        stats: _loadStats(data['stats']),
        learnableMoves: await _loadMoves(data['moves']),
      );

      // Salvar cache
      await prefs.setString('pokemon_$id', json.encode(pokemon.toJson()));
      
      return pokemon;
    } catch (e) {
      debugPrint('Erro ao carregar Pokémon $id: $e');
      return Pokemon.empty();
    }
  }

 static Future<List<Move>> _loadMoves(List<dynamic> moves) async {
  final validMoves = <Move>[];
  for (final moveEntry in moves) {
    try {
      final moveData = moveEntry['move'];
      final moveResponse = await http.get(Uri.parse(moveData['url']));
      if (moveResponse.statusCode != 200) continue;
      
      final moveDetails = jsonDecode(moveResponse.body);
      validMoves.add(Move.fromJson({
        'name': moveData['name'],
        'power': moveDetails['power'] ?? 0,
        'accuracy': moveDetails['accuracy'] ?? 0,
        'type': moveDetails['type'] ?? {'name': 'Normal'},
        'pp': moveDetails['pp'] ?? 5,
        'damage_class': moveDetails['damage_class'] ?? {'name': 'Physical'},
      }));
    } catch (e) {
      debugPrint('Erro em movimento: $e');
    }
  }
  return validMoves;
}

  static List<Stat> _loadStats(List<dynamic> stats) {
    return stats.map((s) {
      try {
        return Stat(
          name: (s['stat']['name'] as String).capitalize(),
          value: s['base_stat'] as int,
        );
      } catch (e) {
        return const Stat(name: 'Erro', value: 0);
      }
    }).toList();
  }
}