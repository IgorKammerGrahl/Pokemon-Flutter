import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/pokemon_card.dart';
import '../providers/pokemon_provider.dart';

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
      final provider = Provider.of<PokemonProvider>(context, listen: false);
      if (provider.availablePokemons.isEmpty) {
        provider.loadPokemons();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.selectionMode 
          ? AppBar(
              title: const Text('Explorar Pokémon'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    final provider = Provider.of<PokemonProvider>(context, listen: false);
                    provider.reset();
                    await provider.loadPokemons();
                  },
                  tooltip: 'Recarregar do zero',
                ),
              ],
            )
          : null,
      body: Consumer<PokemonProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return _buildInitialLoader(provider);
          if (provider.error != null) return _buildError(provider.error!);
          if (provider.availablePokemons.isEmpty) return _buildEmpty();
          
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.pixels == 
                  scrollNotification.metrics.maxScrollExtent) {
                provider.loadPokemons();
              }
              return false;
            },
            child: GridView.builder(
              controller: provider.scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: provider.availablePokemons.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.availablePokemons.length) {
                  return _buildMoreLoader(provider);
                }
                final pokemon = provider.availablePokemons[index];
                return PokemonCard(
                  pokemon: pokemon,
                  onTap: widget.selectionMode 
                      ? () => Navigator.pop(context, pokemon)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialLoader(PokemonProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Carregando ${(provider.loadingProgress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            '${provider.availablePokemons.length} Pokémon carregados',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreLoader(PokemonProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: provider.isLoadingMore
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
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
}