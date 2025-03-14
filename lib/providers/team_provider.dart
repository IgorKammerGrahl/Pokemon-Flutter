import 'package:flutter/material.dart';
import '../battle/models/battle_pokemon.dart';
import '../battle/models/move.dart';
import '../services/storage_service.dart';


class TeamProvider extends ChangeNotifier {
  List<BattlePokemon> _team = [];

  List<BattlePokemon> get team => _team;

  Future<void> _autoSave() async {
    await StorageService.saveTeam(_team);
  }

  void setTeam(List<BattlePokemon> newTeam) {
    _team = newTeam;
    notifyListeners();
    _autoSave();
  }

  void addToTeam(BattlePokemon pokemon) {
    _team.add(pokemon);
    notifyListeners();
    _autoSave();
  }

  void removeFromTeam(int index) {
    _team.removeAt(index);
    notifyListeners();
    _autoSave();
  }

   void updateMoves(int pokemonId, List<Move> newMoves) {
    final index = _team.indexWhere((p) => p.basePokemon.id == pokemonId);
    if (index != -1) {
      _team[index] = _team[index].copyWith(moves: newMoves);
      notifyListeners(); // Isso é crucial para atualizar a UI
      _autoSave();
    }
  }
}