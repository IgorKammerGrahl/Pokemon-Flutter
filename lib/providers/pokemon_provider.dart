import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/poke_api.dart';

class PokemonProvider extends ChangeNotifier {
  List<Pokemon> _availablePokemons = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  final int _pageSize = 20;
  int _currentPage = 0;
  final Set<int> _loadedIds = {};
  bool _hasMore = true;
  final ScrollController scrollController = ScrollController();

  // Filtros
  List<String> _selectedTypes = [];
  int? _selectedGeneration;
  final Map<int, List<int>> _generationRanges = {
    1: [1, 151],
    2: [152, 251],
    3: [252, 386],
    4: [387, 493],
    5: [494, 649],
    6: [650, 721],
    7: [722, 809],
    8: [810, 905],
  };

  List<Pokemon> get availablePokemons => _availablePokemons;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  double get loadingProgress => _hasMore ? _currentPage / (_currentPage + 1) : 1.0;

  // Lista filtrada
  List<Pokemon> get filteredPokemons {
    return _availablePokemons.where((pokemon) {
      final typeMatch = _selectedTypes.isEmpty ||
          pokemon.types.any((type) => _selectedTypes.contains(type));
      
      final generationMatch = _selectedGeneration == null ||
          (pokemon.id >= _generationRanges[_selectedGeneration]![0] &&
           pokemon.id <= _generationRanges[_selectedGeneration]![1]);
      
      return typeMatch && generationMatch;
    }).toList();
  }

  PokemonProvider() {
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      loadPokemons();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadPokemons() async {
    if (!_hasMore || _isLoading || _isLoadingMore) return;

    try {
      if (_currentPage == 0) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      notifyListeners();

      final basicPokemons = await PokeApi.getPokemons(offset: _currentPage * _pageSize);
      
      if (basicPokemons.isEmpty) {
        _hasMore = false;
        return;
      }

      final newPokemons = <Pokemon>[];
      for (final basic in basicPokemons) {
        if (!_loadedIds.contains(basic.id)) {
          final detailed = await _loadSinglePokemon(basic);
          if (detailed != null) {
            newPokemons.add(detailed);
          }
        }
      }

      _availablePokemons.addAll(newPokemons);
      _loadedIds.addAll(newPokemons.map((p) => p.id));
      _currentPage++;

      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar Pokémon: ${e.toString()}';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  int? get selectedGeneration => _selectedGeneration;
  List<String> get selectedTypes => _selectedTypes;
  
  // Métodos para controle dos filtros
  void setSelectedTypes(List<String> types) {
    _selectedTypes = types;
    notifyListeners();
  }

  void setSelectedGeneration(int? generation) {
    _selectedGeneration = generation;
    notifyListeners();
  }

  void clearFilters() {
    _selectedTypes = [];
    _selectedGeneration = null;
    notifyListeners();
  }

  Future<Pokemon?> _loadSinglePokemon(Pokemon basic) async {
    try {
      final pokemon = await PokeApi.getPokemonDetails(basic.id);
      return pokemon.id != 0 ? pokemon : null;
    } catch (e) {
      debugPrint('Erro no Pokémon ${basic.id}: $e');
      return null;
    }
  }

  void reset() {
    _availablePokemons.clear();
    _currentPage = 0;
    _loadedIds.clear();
    _hasMore = true;
    _error = null;
    clearFilters();
    notifyListeners();
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