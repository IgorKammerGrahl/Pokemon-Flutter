import 'dart:math';
import 'package:collection/collection.dart';
import '../models/battle_pokemon.dart';
import '../models/move.dart';
import '../services/type_service.dart';
import '../models/status_effect.dart';

class BattleCalculator {
  static final Random _random = Random();

  // Fórmula oficial de cálculo de dano (geração VI+)
  static Future<int> calculateDamage({
    required BattlePokemon attacker,
    required BattlePokemon defender,
    required Move move,
    bool isCritical = false,
  }) async {
    final attack = _getAttackStat(attacker, move);
    final defense = _getDefenseStat(defender, move);
    
    final stab = _calculateStab(attacker, move);
    final typeEffectiveness = await TypeService.getEffectiveness(
      move.type,
      defender.basePokemon.types
    );
    
    final critical = isCritical ? 1.5 : 1.0;
    final random = 0.85 + (_random.nextDouble() * 0.15);

    final baseDamage = (((2 * attacker.level / 5 + 2) * move.power * attack / defense) / 50 + 2);
    final modifiers = stab * typeEffectiveness * critical * random;

    return (baseDamage * modifiers).round();
  }

  // Verifica se o Pokémon pode atacar
  static bool canAttack(BattlePokemon attacker) {
    final paralysis = attacker.statusEffects.firstWhereOrNull(
      (s) => s.condition == StatusCondition.paralysis
    );
    
    return paralysis == null || _random.nextDouble() > paralysis.effects['move_fail_chance'];
  }

  // Obtém o stat de ataque baseado no tipo de movimento
  static int _getAttackStat(BattlePokemon pokemon, Move move) {
    return move.damageClass == 'physical' 
        ? pokemon.calculateStat('attack')
        : pokemon.calculateStat('special-attack');
  }

  // Obtém o stat de defesa baseado no tipo de movimento
  static int _getDefenseStat(BattlePokemon pokemon, Move move) {
    return move.damageClass == 'physical'
        ? pokemon.calculateStat('defense')
        : pokemon.calculateStat('special-defense');
  }

  // Calcula o STAB (Same Type Attack Bonus)
  static double _calculateStab(BattlePokemon attacker, Move move) {
    return attacker.basePokemon.types.any((t) => t == move.type) ? 1.5 : 1.0;
  }


  // Determina a ordem de ataque
  static bool attacksFirst(BattlePokemon a, BattlePokemon b, Move moveA, Move moveB) {
    // Prioridade de movimento
    final priorityDiff = moveA.priority - moveB.priority;
    if (priorityDiff != 0) return priorityDiff > 0;

    // Comparação de speed
    return a.calculateStat('speed') > b.calculateStat('speed');
  }

  // Verifica se o movimento acerta um crítico
  static bool checkCriticalHit(BattlePokemon attacker, Move move) {
    final critChance = move.highCritRatio ? 0.25 : 0.0417;
    return _random.nextDouble() < critChance;
  }

  // Verifica se o movimento acerta o alvo
  static bool doesMoveHit(Move move, BattlePokemon attacker, BattlePokemon defender) {
    final accuracy = move.accuracy / 100;
    return _random.nextDouble() < accuracy;
  }
}