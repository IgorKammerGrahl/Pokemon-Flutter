import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';
import 'dart:convert';

class StorageService {
  static const String _teamKey = 'saved_team';

  // Salva o time no dispositivo
  static Future<void> saveTeam(List<Pokemon> team) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> teamJson = team.map((p) => json.encode(p.toJson())).toList();
    prefs.setStringList(_teamKey, teamJson);
  }

  // Carrega o time salvo
  static Future<List<Pokemon>> getTeam() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? teamJson = prefs.getStringList(_teamKey);
  
  return teamJson?.map((jsonStr) {
    var decodedJson = json.decode(jsonStr);
    return Pokemon(
      name: decodedJson['name'],
      url: decodedJson['url'],
      imageUrl: decodedJson['imageUrl'],
      types: decodedJson['types']?.cast<String>(),
      id: decodedJson['id'],
    );
  }).toList() ?? [];
}
}