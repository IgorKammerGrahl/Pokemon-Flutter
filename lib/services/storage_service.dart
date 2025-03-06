import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';
import 'dart:convert';

class StorageService {
  static const String _teamKey = 'saved_team';

  static Future<void> saveTeam(List<Pokemon> team) async {
    final prefs = await SharedPreferences.getInstance();
    final teamJson = team.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList(_teamKey, teamJson);
  }

  static Future<List<Pokemon>> getTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final teamJson = prefs.getStringList(_teamKey) ?? [];
    
    return teamJson.map((jsonStr) {
      final decoded = json.decode(jsonStr);
      return Pokemon.fromJson(decoded);
    }).toList();
  }
}