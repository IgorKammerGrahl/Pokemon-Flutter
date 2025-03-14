import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon.dart';
import '../battle/models/battle_pokemon.dart';
import '../services/storage_service.dart';
import 'move_selection_dialog.dart';
import '../providers/team_provider.dart';
import '../providers/pokemon_provider.dart';
import '../battle/models/move.dart';
import '../services/poke_api.dart';
import 'type_filter.dart';

class TeamBuilderPage extends StatelessWidget {
  const TeamBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PokemonProvider>(
      builder: (context, pokemonProvider, _) {
        return Consumer<TeamProvider>(
          builder: (context, teamProvider, _) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Montar Equipe'),
                actions: [
                  _buildFilterButton(context),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      await StorageService.saveTeam(teamProvider.team);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Time salvo com sucesso!')),
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  _buildFilterControls(pokemonProvider),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: pokemonProvider.filteredPokemons.length,
                      itemBuilder: (context, index) {
                        final pokemon = pokemonProvider.filteredPokemons[index];
                        return _PokemonCard(
                          pokemon: pokemon,
                          onAdd: () => _addPokemon(context, pokemon),
                          onEdit: () => _editMoves(context, pokemon),
                          isInTeam: teamProvider.team.any((p) => p.basePokemon.id == pokemon.id),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  _buildTeamSection(context, teamProvider.team),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.filter_alt),
      onPressed: () => _showFilterDialog(context),
    );
  }

Widget _buildFilterControls(PokemonProvider provider) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dropdown de Geração
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.yellow[100],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<int>(
              value: provider.selectedGeneration,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    'Todas Gerações',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(8, (i) => i + 1).map(
                  (gen) => DropdownMenuItem(
                    value: gen,
                    child: Text(
                      'Gen $gen',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: (value) => provider.setSelectedGeneration(value),
              decoration: const InputDecoration(
                labelText: 'Geração',
                border: InputBorder.none,
              ),
              dropdownColor: Colors.yellow[100],
              icon: Icon(Icons.arrow_drop_down, color: Colors.red[800]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Filtro de Tipos
       ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 40,
            maxHeight: 100, // Altura máxima permitida
          ),
          child: SingleChildScrollView(
            child: TypeFilter(provider: provider),
          ),
        )
      ],
    ),
  );
}



  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtros Avançados'),
        content: SingleChildScrollView(
          child: Consumer<PokemonProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  _buildGenerationFilter(provider, dialogContext),
                  const SizedBox(height: 20),
                  TypeFilter(provider: provider), // Componente reutilizado
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationFilter(PokemonProvider provider, BuildContext dialogContext) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Geração:', style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.red[800]
      )),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(8, (i) => i + 1).map((gen) => ChoiceChip(
          label: Text('Gen $gen', style: TextStyle(
            color: provider.selectedGeneration == gen 
                ? Colors.white 
                : Colors.grey[800]
          )),
          selected: provider.selectedGeneration == gen,
          selectedColor: Colors.red[800],
          backgroundColor: Colors.yellow[100],
          shape: StadiumBorder(
            side: BorderSide(color: Colors.grey[400]!)
          ),
          onSelected: (selected) {
            provider.setSelectedGeneration(selected ? gen : null);
            Navigator.pop(dialogContext);
          },
        )).toList(),
      ),
    ],
  );
}



  Widget _buildTeamSection(BuildContext context, List<BattlePokemon> team) {
    return SizedBox(
      height: 120,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: team.length,
        onReorder: (oldIndex, newIndex) => _reorderTeam(context, oldIndex, newIndex),
        itemBuilder: (context, index) => _TeamMember(
          key: Key(team[index].basePokemon.id.toString()),
          pokemon: team[index],
          onRemove: () => _removePokemon(context, index),
        ),
      ),
    );
  }

  Future<void> _addPokemon(BuildContext context, Pokemon basePokemon) async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    
    if (teamProvider.team.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipe cheia (máx. 6 Pokémon)')),
      );
      return;
    }

    final detailedPokemon = await PokeApi.getPokemonDetails(basePokemon.id);
    
    final battlePokemon = BattlePokemon.fromBase(
      detailedPokemon,
      moves: detailedPokemon.learnableMoves.take(4).toList(),
      level: 50,
    );
    
    teamProvider.addToTeam(battlePokemon);
  }

  Future<void> _editMoves(BuildContext context, Pokemon pokemon) async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final battlePokemon = teamProvider.team.firstWhere(
      (p) => p.basePokemon.id == pokemon.id,
    );

    final selectedMoves = await showDialog<List<Move>>(
      context: context,
      builder: (context) => MoveSelectionDialog(
        availableMoves: battlePokemon.basePokemon.learnableMoves,
        initialSelection: battlePokemon.moves,
      ),
    );

    if (selectedMoves != null && selectedMoves.isNotEmpty) {
      teamProvider.updateMoves(pokemon.id, selectedMoves);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movimentos de ${pokemon.name} atualizados!')),
      );
    }
  }

  void _reorderTeam(BuildContext context, int oldIndex, int newIndex) {
    final provider = Provider.of<TeamProvider>(context, listen: false);
    final newTeam = List<BattlePokemon>.from(provider.team);
    
    if (newIndex > newTeam.length) newIndex = newTeam.length;
    final item = newTeam.removeAt(oldIndex);
    newTeam.insert(newIndex, item);
    
    provider.setTeam(newTeam);
  }

  void _removePokemon(BuildContext context, int index) {
    final provider = Provider.of<TeamProvider>(context, listen: false);
    provider.removeFromTeam(index);
  }
}

class _PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final bool isInTeam;

  const _PokemonCard({
    required this.pokemon,
    required this.onAdd,
    required this.onEdit,
    required this.isInTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              pokemon.imageUrl,
              headers: const {'User-Agent': 'PokeApp/1.0'},
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
              loadingBuilder: (_, child, progress) =>
                progress == null ? child : const CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              pokemon.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          isInTeam
              ? IconButton(icon: const Icon(Icons.edit), onPressed: onEdit)
              : IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final BattlePokemon pokemon;
  final VoidCallback onRemove;

  const _TeamMember({
    required super.key,
    required this.pokemon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Image.network(
                pokemon.basePokemon.imageUrl,
                width: 80,
                height: 80,
                headers: const {'User-Agent': 'PokeApp/1.0'},
                errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 40),
              ),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: onRemove,
                ),
              ),
            ],
          ),
          Text(
            pokemon.basePokemon.name,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}