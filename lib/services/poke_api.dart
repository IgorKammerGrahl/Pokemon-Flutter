import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApi {
  // Método removido o _baseUrl não utilizado

  // Busca lista de Pokémon
  static Future<List<Pokemon>> getPokemons({int limit = 200}) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((p) => Pokemon.fromListJson(p)).toList();
    } else {
      throw Exception('Falha ao carregar Pokémon');
    }
  }

  // Busca detalhes de um Pokémon
  static Future<Pokemon> getPokemonDetails(int id) async {
  final response = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon/$id/')
  );
  
  if (response.statusCode == 200) {
    return Pokemon.fromDetailJson(json.decode(response.body));
  } else {
    throw Exception('Falha ao carregar detalhes');
  }
}
}