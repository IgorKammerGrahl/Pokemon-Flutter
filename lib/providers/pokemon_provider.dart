import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api.dart';

class PokemonProvider extends ChangeNotifier {
  List<Pokemon> _availablePokemons = [];
  bool _isLoading = false;
  String? _error;
  int _loadedCount = 0;
  int _totalToLoad = 0;
  final int _chunkSize = 10; // Processar em grupos de 10

  List<Pokemon> get availablePokemons => _availablePokemons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get loadingProgress => _totalToLoad > 0 ? _loadedCount / _totalToLoad : 0;

   int get loadedCount => _loadedCount;
   int get totalToLoad => _totalToLoad;

  Future<void> loadPokemons() async {
    try {
      _isLoading = true;
      _error = null;
      _loadedCount = 0;
      _totalToLoad = 0;
      notifyListeners();

      final basicPokemons = await PokeApi.getPokemons();
      _totalToLoad = basicPokemons.length;
      
      // Processar em chunks paralelos
      for (var i = 0; i < basicPokemons.length; i += _chunkSize) {
        final chunk = basicPokemons.sublist(i, i + _chunkSize > basicPokemons.length 
            ? basicPokemons.length 
            : i + _chunkSize);
        
        await Future.wait(chunk.map((p) => _loadSinglePokemon(p)));
        _loadedCount += chunk.length;
        notifyListeners(); // Notificar a cada chunk
      }

    } catch (e) {
      _error = 'Erro ao carregar Pokémon: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSinglePokemon(Pokemon basicPokemon) async {
    try {
      final pokemon = await PokeApi.getPokemonDetails(basicPokemon.id);
      if (pokemon.id != 0) {
        _availablePokemons.add(pokemon);
      }
    } catch (e) {
      debugPrint('Erro no Pokémon ${basicPokemon.id}: $e');
    }
  }

  Future<void> loadPokemonDetails(int id) async {
    try {
      final pokemon = await PokeApi.getPokemonDetails(id);
      final index = _availablePokemons.indexWhere((p) => p.id == id);
      if (index != -1) {
        _availablePokemons[index] = pokemon;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar detalhes do Pokémon $id: $e');
    }
  }
}