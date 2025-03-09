import 'package:flutter/material.dart';
import '../battle/models/battle_pokemon.dart';
import '../battle/models/move.dart';

class TeamProvider extends ChangeNotifier {
  List<BattlePokemon> _team = [];

  List<BattlePokemon> get team => _team;

  void setTeam(List<BattlePokemon> newTeam) {
    _team = newTeam;
    notifyListeners();
  }

  void addToTeam(BattlePokemon pokemon) {
    _team.add(pokemon);
    notifyListeners();
  }

  void removeFromTeam(int index) {
    _team.removeAt(index);
    notifyListeners();
  }

   void updateMoves(int pokemonId, List<Move> newMoves) {
    final index = _team.indexWhere((p) => p.basePokemon.id == pokemonId);
    if (index != -1) {
      _team[index] = _team[index].copyWith(moves: newMoves);
      notifyListeners(); // Isso é crucial para atualizar a UI
    }
  }
}