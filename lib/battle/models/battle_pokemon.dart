import 'dart:math';
import 'package:projeto_tcg/models/pokemon.dart';
import 'status_effect.dart';
import 'move.dart';

class BattlePokemon {
  final Pokemon basePokemon;
  final int level;
  final Map<String, int> ivs;
  final Map<String, int> evs;
  List<Move> moves;
  int currentHp;
  String currentStatus;
  List<StatusEffect> statusEffects = [];
  bool isConfused = false;

  BattlePokemon({
    required this.basePokemon,
    required this.level,
    required this.ivs,
    required this.evs,
    required this.moves,
    required this.currentHp,
    this.currentStatus = 'none',
  });

   factory BattlePokemon.fromBase(
    Pokemon base, {
    int level = 50,
    required List<Move> moves, // Adicione este parâmetro
  }) {
    final ivs = _generateRandomIVs();
    final evs = _defaultEVs();
    
    final baseHpStat = base.stats.firstWhere(
      (s) => s.name == 'hp',
      orElse: () => const Stat(name: 'hp', value: 0),
    ).value;
    
    final hp = (((2 * baseHpStat + ivs['hp']! + (evs['hp']! ~/ 4)) * level) ~/ 100) + level + 10;

    return BattlePokemon(
      basePokemon: base,
      level: level,
      ivs: ivs,
      evs: evs,
      moves: moves, // Use o parâmetro recebido
      currentHp: hp,
    );
  }

  static Map<String, int> _generateRandomIVs() {
    final random = Random();
    return {
      'hp': random.nextInt(32),
      'attack': random.nextInt(32),
      'defense': random.nextInt(32),
      'special-attack': random.nextInt(32),
      'special-defense': random.nextInt(32),
      'speed': random.nextInt(32),
    };
  }

  static Map<String, int> _defaultEVs() => {
        'hp': 0,
        'attack': 0,
        'defense': 0,
        'special-attack': 0,
        'special-defense': 0,
        'speed': 0,
      };

  int calculateStat(String stat) {
    final baseStat = basePokemon.stats.firstWhere(
      (s) => s.name == stat,
      orElse: () => const Stat(name: 'hp', value: 0),
    ).value;

    if (stat == 'hp') {
      return (((2 * baseStat + ivs[stat]! + (evs[stat]! ~/ 4)) * level) ~/ 100) + level + 10;
    }
    
    return ((((2 * baseStat + ivs[stat]! + (evs[stat]! ~/ 4)) * level) ~/ 100) + 5);
  }

  void takeDamage(int damage) {
    currentHp = (currentHp - damage).clamp(0, calculateStat('hp'));
  }
  // Aplicar novo status
  void addStatus(StatusEffect newStatus) {
    if (basePokemon.types.contains("poison") && newStatus.condition == StatusCondition.poison) return;
    
    final statusConditions = [StatusCondition.burn, StatusCondition.poison, StatusCondition.paralysis, StatusCondition.sleep];
    if (statusConditions.contains(newStatus.condition)) {
      statusEffects.removeWhere((s) => s.condition == newStatus.condition);
    }
    
    statusEffects.add(newStatus);
  }

  // Remover status
  void removeStatus(StatusCondition condition) {
    statusEffects.removeWhere((s) => s.condition == condition);
  }

  // Verificar se pode agir
   bool canMove() {
    for (final status in statusEffects) {
      if (status.effects['prevents_move'] == true) {
        if (status.condition == StatusCondition.freeze && Random().nextDouble() < 0.2) {
          removeStatus(StatusCondition.freeze);
          return true;
        }
        return false;
      }
    }
    return true;
  }

  // Modificadores de batalha
  double getAttackModifier() {
    return statusEffects.fold(1.0, (prev, status) => prev * (status.effects['attack_multiplier'] ?? 1.0));
  }

  double getSpeedModifier() {
    return statusEffects.fold(1.0, (prev, status) => prev * (status.effects['speed_multiplier'] ?? 1.0));
  }
}