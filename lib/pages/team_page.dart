import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/pokemon.dart';
import '../repositories/team_repository.dart';
import '../pages/explore_page.dart';
import '../widgets/pokemon_card.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TeamRepository _repository = TeamRepository();
  late Future<List<Team>> _teamsFuture;
  String? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _teamsFuture = _repository.getTeams();
  }

  void _refreshTeams() {
    setState(() {
      _teamsFuture = _repository.getTeams();
    });
  }

  Future<void> _createNewTeam() async {
    final nameController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Time'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome do Time',
            hintText: 'Ex: Time Principal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _repository.createTeam(nameController.text);
                _refreshTeams();
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Times Pokémon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: _createNewTeam,
            tooltip: 'Criar novo time',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddPokemon,
            tooltip: 'Adicionar Pokémon',
          ),
        ],
      ),
      body: FutureBuilder<List<Team>>(
        future: _teamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final teams = snapshot.data ?? [];
          
          if (teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhum time criado'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createNewTeam,
                    child: const Text('Criar Primeiro Time'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Seletor de Times
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: teams.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return InputChip(
                      label: Text(team.name),
                      selected: _selectedTeamId == team.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTeamId = selected ? team.id : null;
                        });
                      },
                      deleteIcon: const Icon(Icons.more_vert, size: 18),
                      onDeleted: () {
                        _showTeamOptions(context, team);
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Grid de Pokémon
              if (_selectedTeamId != null)
                Expanded(
                  child: _buildTeamGrid(
                    teams.firstWhere((t) => t.id == _selectedTeamId),
                  ),
                )
              else
                const Expanded(
                  child: Center(child: Text('Selecione um time')),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeamGrid(Team team) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: team.pokemons.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAddPokemonButton(team);
        }
        final pokemon = team.pokemons[index - 1];
        return _buildPokemonCard(team, pokemon);
      },
    );
  }

  Widget _buildAddPokemonButton(Team team) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToAddPokemon(),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 40),
              SizedBox(height: 8),
              Text('Adicionar Pokémon'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonCard(Team team, Pokemon pokemon) {
    return Stack(
      children: [
        PokemonCard(pokemon: pokemon),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removePokemon(team.id, pokemon),
          ),
        ),
      ],
    );
  }

  void _removePokemon(String teamId, Pokemon pokemon) async {
    await _repository.removeFromTeam(teamId, pokemon.id.toString());
    _refreshTeams();
  }

  void _renameTeam(Team team) async {
    final nameController = TextEditingController(text: team.name);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear Time'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Novo nome',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _repository.renameTeam(team.id, nameController.text);
                _refreshTeams();
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showTeamOptions(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Renomear'),
            onTap: () {
              Navigator.pop(context);
              _renameTeam(team);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Excluir'),
            onTap: () async {
              await _repository.deleteTeam(team.id);
              _refreshTeams();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToAddPokemon() async {
    if (_selectedTeamId == null) return;
    
    final selectedPokemon = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExplorePage(selectionMode: true),
      ),
    );

    if (selectedPokemon != null) {
      try {
        await _repository.addToTeam(_selectedTeamId!, selectedPokemon);
        _refreshTeams();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}