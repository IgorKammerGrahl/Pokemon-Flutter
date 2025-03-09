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
    // Chama o carregamento diretamente do provider
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
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
            ),
            itemCount: provider.availablePokemons.length,
            itemBuilder: (context, index) {
              final pokemon = provider.availablePokemons[index];
              return PokemonCard(
                pokemon: pokemon,
                onTap: widget.selectionMode 
                    ? () => Navigator.pop(context, pokemon)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}