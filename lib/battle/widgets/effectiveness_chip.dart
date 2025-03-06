import 'package:flutter/foundation.dart';
import 'package:projeto_tcg/models/pokemon.dart';

class BattlePokemon {
  final Pokemon basePokemon;
  final int level;
  final Map<String, int> ivs;
  final Map<String, int> evs;
  List<Move> moves;
  int currentHp;
  String currentStatus;

  BattlePokemon({
    required this.basePokemon,
    this.level = 50,
    required this.ivs,
    required this.evs,
    required this.moves,
    required this.currentHp,
    this.currentStatus = 'none',
  });

  // Cria um BattlePokemon a partir de um Pokémon base com valores padrão
  factory BattlePokemon.fromBase(Pokemon base, {int level = 50}) {
    return BattlePokemon(
      basePokemon: base,
      level: level,
      ivs: _generateRandomIVs(),
      evs: _defaultEVs(),
      moves: [],
      currentHp: 0,
    )..currentHp = calculateStat('hp');
  }

  // Gera IVs aleatórios (0-31) para cada stat
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

  // Valores iniciais de EVs
  static Map<String, int> _defaultEVs() => {
        'hp': 0,
        'attack': 0,
        'defense': 0,
        'special-attack': 0,
        'special-defense': 0,
        'speed': 0,
      };

  // Cálculo de stats usando a fórmula oficial
  int calculateStat(String stat) {
    final baseStat = basePokemon.stats!.firstWhere(
      (s) => s.name == stat,
      orElse: () => const Stat(name: 'hp', value: 0),
    ).value;

    if (stat == 'hp') {
      return (((2 * baseStat + ivs[stat]! + (evs[stat]! ~/ 4)) * level) ~/ 100 +
          level +
          10;
    }
    
    return ((((2 * baseStat + ivs[stat]! + (evs[stat]! ~/ 4)) * level) ~/ 100) +
        5;
  }

  // Métodos de batalha
  void takeDamage(int damage) {
    currentHp = (currentHp - damage).clamp(0, calculateStat('hp'));
  }

  void restoreHp(int amount) {
    currentHp = (currentHp + amount).clamp(0, calculateStat('hp'));
  }

  bool isFainted() => currentHp <= 0;

  // Para persistência de dados
  Map<String, dynamic> toJson() => {
        'base': basePokemon.toJson(),
        'level': level,
        'ivs': ivs,
        'evs': evs,
        'moves': moves.map((m) => m.toJson()).toList(),
        'current_hp': currentHp,
        'status': currentStatus,
      };

  factory BattlePokemon.fromJson(Map<String, dynamic> json) {
    return BattlePokemon(
      basePokemon: Pokemon.fromJson(json['base']),
      level: json['level'],
      ivs: Map<String, int>.from(json['ivs']),
      evs: Map<String, int>.from(json['evs']),
      moves: (json['moves'] as List).map((m) => Move.fromJson(m)).toList(),
      currentHp: json['current_hp'],
      currentStatus: json['status'],
    );
  }
}

// Modelo auxiliar para Moves
class Move {
  final String name;
  final int power;
  final int accuracy;
  final String type;
  final int pp;
  final String damageClass;

  Move({
    required this.name,
    required this.power,
    required this.accuracy,
    required this.type,
    required this.pp,
    required this.damageClass,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'power': power,
        'accuracy': accuracy,
        'type': type,
        'pp': pp,
        'damage_class': damageClass,
      };

  factory Move.fromJson(Map<String, dynamic> json) => Move(
        name: json['name'],
        power: json['power'] ?? 0,
        accuracy: json['accuracy'] ?? 100,
        type: json['type'],
        pp: json['pp'] ?? 10,
        damageClass: json['damage_class'],
      );
}

// Extensão para o modelo base de Pokemon
class Stat {
  final String name;
  final int value;

  const Stat({required this.name, required this.value});
}