import 'dart:convert';
import 'package:http/http.dart' as http;

class TypeService {
  static const _baseUrl = 'https://pokeapi.co/api/v2/type';
  static final Map<String, Map<String, double>> _cache = {};

  static Future<double> getEffectiveness(String attackType, List<String> defendTypes) async {
    if (!_cache.containsKey(attackType)) {
      await _loadTypeData(attackType);
    }
    
    double effectiveness = 1.0;
    final relations = _cache[attackType]!;
    
    for (final defendType in defendTypes) {
      effectiveness *= relations[defendType] ?? 1.0;
    }
    
    return effectiveness;
  }

  static Future<void> _loadTypeData(String type) async {
    final response = await http.get(Uri.parse('$_baseUrl/$type'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final relations = data['damage_relations'];
      
      _cache[type] = {
        for (var type in relations['double_damage_to']) type['name'] as String: 2.0,
        for (var type in relations['half_damage_to']) type['name'] as String: 0.5,
        for (var type in relations['no_damage_to']) type['name'] as String: 0.0,
      };
    }
  }
}