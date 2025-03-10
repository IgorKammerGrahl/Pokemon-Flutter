library move;
import 'dart:math';
import 'battle_pokemon.dart';
import 'status_effect.dart';
import '../../extensions/string_extensions.dart';

class Move {
  final String name;
  final int power;
  final int accuracy;
  final String type;
  final int pp;
  final String damageClass;
  final int priority;
  final bool highCritRatio;
  final Map<StatusCondition, double>? statusEffects;

   Move({
    required this.name,
    required this.power,
    required this.accuracy,
    required this.type,
    required this.pp,
    required this.damageClass,
    this.priority = 0,
    this.highCritRatio = false,
    this.statusEffects,
  }); 

    Move.empty()
      : name = 'Unknown',
        power = 0,
        accuracy = 0,
        type = 'Normal',
        pp = 0,
        damageClass = 'Physical',
        priority = 0,
        highCritRatio = false,
        statusEffects = null;

  // Método para desserialização
  factory Move.fromJson(Map<String, dynamic> json) {
  return Move(
    name: json['name'] as String? ?? 'Unknown Move',
    power: json['power'] as int? ?? 0,
    accuracy: json['accuracy'] as int? ?? 100,
    type: (json['type']?['name'] as String?)?.capitalize() ?? 'Normal', // Null check
    pp: json['pp'] as int? ?? 5,
    damageClass: (json['damage_class']?['name'] as String?)?.capitalize() ?? 'Physical',
    priority: json['priority'] as int? ?? 0,
    highCritRatio: (json['meta']?['crit_rate'] as int? ?? 0) == 1,
  );
}


  // Método para serialização
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'power': power,
      'accuracy': accuracy,
      'type': {'name': type.toLowerCase()},
      'pp': pp,
      'damage_class': {'name': damageClass.toLowerCase()},
      'priority': priority,
      'meta': {'crit_rate': highCritRatio ? 1 : 0},
    };
  }

  void applySecondaryEffects(BattlePokemon target) {
    if (statusEffects != null) {
      final random = Random();
      statusEffects!.forEach((condition, chance) {
        if (random.nextDouble() < chance) {
          target.addStatus(StatusEffect(
            condition: condition,
            duration: condition == StatusCondition.sleep 
                ? random.nextInt(3) + 1 
                : -1,
          ));
        }
      });
    }
  }
}