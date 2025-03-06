import 'dart:math';
import 'battle_pokemon.dart';

enum StatusCondition { burn, freeze, paralysis, poison, sleep, confusion }

class StatusEffect {
  final StatusCondition condition;
  int duration;
  double probability;

  StatusEffect({
    required this.condition,
    this.duration = -1,
    this.probability = 1.0,
  });
  // Efeitos por condição
  Map<String, dynamic> get effects {
    switch (condition) {
      case StatusCondition.burn:
        return {'attack_multiplier': 0.5, 'damage_per_turn': 1/16};
      case StatusCondition.paralysis:
        return {'speed_multiplier': 0.25, 'fail_chance': 0.25};
      case StatusCondition.freeze:
        return {'prevent_move': true, 'thaw_chance': 0.2};
      case StatusCondition.poison:
        return {'damage_per_turn': 1/8};
      case StatusCondition.sleep:
        return {'prevent_move': true};
      case StatusCondition.confusion:
        return {'self_damage_chance': 0.33};
    }
  }

  // Aplicar efeito no final do turno
  void applyEndOfTurnEffect(BattlePokemon pokemon) {
    switch (condition) {
      case StatusCondition.burn:
      case StatusCondition.poison:
        final damage = (pokemon.calculateStat('hp') * effects['end_of_turn_damage']).round();
        pokemon.takeDamage(damage);
        break;
      case StatusCondition.confusion:
        if (Random().nextDouble() < effects['self_damage_chance']) {
          final damage = (pokemon.calculateStat('hp') * 0.25).round();
          pokemon.takeDamage(damage);
        }
        break;
      default:
        break;
    }
  }

  // Verificar cura
  bool checkRecovery() {
    if (duration > 0) duration--;
    
    switch (condition) {
      case StatusCondition.freeze:
        return Random().nextDouble() < effects['thaw_chance'];
      case StatusCondition.sleep:
        return duration <= 0;
      default:
        return false; // Status permanentes só curam com itens/habilidades
    }
  }
}