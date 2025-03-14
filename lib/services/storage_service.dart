  import 'package:shared_preferences/shared_preferences.dart';
  import 'dart:convert';
  import '../battle/models/battle_pokemon.dart';

  class StorageService {
    static const _teamKey = 'saved_team';

    static Future<void> saveTeam(List<BattlePokemon> team) async {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = team.map((p) => p.toJson()).toList();
      await prefs.setString(_teamKey, jsonEncode(jsonList));
    }

    static Future<List<BattlePokemon>> getTeam() async {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_teamKey);
      
      if (jsonString == null) return [];
      
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList.map((e) => BattlePokemon.fromJson(e)).toList();
      } catch (e) {
        print('Erro ao carregar time: $e');
        return [];
      }
    }
  }