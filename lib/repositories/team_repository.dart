import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';
import '../models/pokemon.dart';

class TeamRepository {
  static const _teamsKey = 'saved_teams';

  Future<List<Team>> getTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_teamsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Team.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao carregar times: $e');
      return [];
    }
  }

  Future<void> saveTeams(List<Team> teams) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_teamsKey, json.encode(teams));
  }

  Future<void> createTeam(String name) async {
    final teams = await getTeams();
    teams.add(Team(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      pokemons: [],
    ));
    await saveTeams(teams);
  }

  Future<void> deleteTeam(String teamId) async {
    final teams = await getTeams();
    teams.removeWhere((t) => t.id == teamId);
    await saveTeams(teams);
  }

  Future<void> renameTeam(String teamId, String newName) async {
    final teams = await getTeams();
    final team = teams.firstWhere((t) => t.id == teamId);
    team.name = newName;
    await saveTeams(teams);
  }

  Future<void> addToTeam(String teamId, Pokemon pokemon) async {
    final teams = await getTeams();
    final team = teams.firstWhere((t) => t.id == teamId);
    
    if (team.pokemons.length >= 6) {
      throw Exception('Time completo (máximo 6 Pokémon)');
    }
    
    team.pokemons.add(pokemon);
    await saveTeams(teams);
  }

  Future<void> removeFromTeam(String teamId, String pokemonId) async {
    final teams = await getTeams();
    final team = teams.firstWhere((t) => t.id == teamId);
    team.pokemons.removeWhere((p) => p.id.toString() == pokemonId);
    await saveTeams(teams);
  }
}