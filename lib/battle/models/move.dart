import 'dart:math';
import 'battle_pokemon.dart';
import 'status_effect.dart';

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
}) : assert(power >= 0),
     assert(accuracy >= 0 && accuracy <= 100),
     assert(pp > 0);

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