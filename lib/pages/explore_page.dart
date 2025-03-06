import 'package:flutter/material.dart';
import '../services/poke_api.dart';
import '../models/pokemon.dart';
import '../widgets/pokemon_card.dart';

class ExplorePage extends StatelessWidget {
  final bool selectionMode;

  const ExplorePage({super.key, this.selectionMode = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectionMode 
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
      body: FutureBuilder<List<Pokemon>>(
        future: PokeApi.getPokemons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum Pokémon encontrado'));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pokemon = snapshot.data![index];
                return FutureBuilder<Pokemon>(
                  future: PokeApi.getPokemonDetails(pokemon.url),
                  builder: (context, detailSnapshot) {
                    if (detailSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (detailSnapshot.hasError) {
                      return Center(child: Text('Erro: ${detailSnapshot.error}'));
                    } else if (!detailSnapshot.hasData) {
                      return const Center(child: Text('Detalhes não encontrados'));
                    } else {
                      final pokemon = detailSnapshot.data!;
                      return PokemonCard(
                        pokemon: pokemon,
                        onTap: selectionMode
                            ? () => Navigator.pop(context, pokemon)
                            : null,
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
