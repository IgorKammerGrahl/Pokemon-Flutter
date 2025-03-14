import 'package:flutter/material.dart';
import '../providers/pokemon_provider.dart';

class TypeFilter extends StatelessWidget {
  final PokemonProvider provider;

  const TypeFilter({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Filtrar por Tipo:',
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(
          height: 60,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: 
                ['Normal', 'Fire', 'Water', 'Electric', 'Grass', 'Ice',
                 'Fighting', 'Poison', 'Ground', 'Flying', 'Psychic',
                 'Bug', 'Rock', 'Ghost', 'Dragon', 'Dark', 'Steel', 'Fairy']
                .map<Widget>((type) => ChoiceChip(
                  label: Text(type),
                  labelStyle: const TextStyle(fontSize: 14),
                  selected: provider.selectedTypes.contains(type),
                  onSelected: (bool selected) {
                    final newTypes = List<String>.from(provider.selectedTypes);
                    selected ? newTypes.add(type) : newTypes.remove(type);
                    provider.setSelectedTypes(newTypes);
                  },
                )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
