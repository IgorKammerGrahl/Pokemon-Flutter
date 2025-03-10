import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import 'package:provider/provider.dart'; 

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(pokemon.types.isNotEmpty 
    ? pokemon.types.first 
    : 'Normal');
    
    return GestureDetector(
        onTap: () {
        if (pokemon.learnableMoves.isEmpty) {
          final provider = Provider.of<PokemonProvider>(context, listen: false);
          provider.loadPokemonDetails(pokemon.id);
        }
        onTap?.call();
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                typeColor.withOpacity(0.15),
                typeColor.withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ID e Imagem
                Stack(
                  children: [
                    // Número do Pokémon
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Text(
                        '#${pokemon.id.toString().padLeft(3, '0')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: typeColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    // Imagem centralizada
                    Center(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            color: typeColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Nome e Tipos
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nome
                      Text(
                        pokemon.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: typeColor,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Tipos
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        alignment: WrapAlignment.center,
                        children: pokemon.types.take(2).map((type) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    const typeColors = {
      'Fire': Color(0xFFFF9741),
      'Water': Color(0xFF3692DC),
      'Grass': Color(0xFF74CB48),
      'Electric': Color(0xFFF8D030),
      'Psychic': Color(0xFFF85888),
      'Ice': Color(0xFF98D8D8),
      'Dragon': Color(0xFF7038F8),
      'Dark': Color(0xFF705848),
      'Fairy': Color(0xFFEE99AC),
      'Normal': Color(0xFFA8A878),
      'Fighting': Color(0xFFC03028),
      'Flying': Color(0xFFA890F0),
      'Poison': Color(0xFFA040A0),
      'Ground': Color(0xFFE0C068),
      'Rock': Color(0xFFB8A038),
      'Bug': Color(0xFFA8B820),
      'Ghost': Color(0xFF705898),
      'Steel': Color(0xFFB8B8D0),
    };
    return typeColors[type] ?? const Color(0xFF68A090);
  }
}