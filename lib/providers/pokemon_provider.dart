import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api.dart'; // Importe o serviço de API

class PokemonProvider extends ChangeNotifier {
  List<Pokemon> _availablePokemons = [];
  bool _isLoading = false;
  String? _error;

  List<Pokemon> get availablePokemons => _availablePokemons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPokemons() async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Carrega lista básica de Pokémon
      final basicPokemons = await PokeApi.getPokemons();
      
      // 2. Carrega detalhes completos de cada Pokémon
      _availablePokemons = await Future.wait(
        basicPokemons.map((p) => PokeApi.getPokemonDetails(p.id)),
      );

      _error = null;
    } catch (e) {
      _error = 'Falha ao carregar Pokémon: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Atualiza um Pokémon específico (útil para dados dinâmicos)
  void updatePokemon(Pokemon updatedPokemon) {
    final index = _availablePokemons.indexWhere((p) => p.id == updatedPokemon.id);
    if (index != -1) {
      _availablePokemons[index] = updatedPokemon;
      notifyListeners();
    }
  }
}