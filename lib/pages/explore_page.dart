import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/pokemon_card.dart';
import '../providers/pokemon_provider.dart';
import '../models/pokemon.dart';

class ExplorePage extends StatefulWidget {
  final bool selectionMode;
  const ExplorePage({super.key, this.selectionMode = false});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PokemonProvider>(context, listen: false).loadPokemons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.selectionMode 
          ? AppBar(
              title: const Text('Selecione um Pokémon'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            )
          : null,
      body: Consumer<PokemonProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return _buildLoading(provider);
          }
          
          if (provider.error != null) {
            return _buildError(provider.error!);
          }

          if (provider.availablePokemons.isEmpty) {
            return _buildEmpty();
          }

          return _buildGrid(provider.availablePokemons);
        },
      ),
    );
  }

  Widget _buildLoading(PokemonProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Carregando ${provider.loadingProgress.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            '(${provider.loadedCount}/${provider.totalToLoad})',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          error,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'Nenhum Pokémon encontrado',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildGrid(List<Pokemon> pokemons) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: pokemons.length,
      itemBuilder: (context, index) {
        final pokemon = pokemons[index];
        return PokemonCard(
          pokemon: pokemon,
          onTap: widget.selectionMode 
              ? () => Navigator.pop(context, pokemon)
              : null,
        );
      },
    );
  }
}