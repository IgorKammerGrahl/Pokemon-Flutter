import 'package:flutter/material.dart';
import '../services/type_service.dart';

class EffectivenessChip extends StatelessWidget {
  final String attackingType;
  final List<String> defendingTypes;

  const EffectivenessChip({
    super.key,
    required this.attackingType,
    required this.defendingTypes,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: TypeService.getEffectiveness(attackingType, defendingTypes),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Chip(
            label: Text('×${snapshot.data!.toStringAsFixed(1)}'),
            backgroundColor: _getColor(snapshot.data!),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Color _getColor(double effectiveness) {
    if (effectiveness >= 2) return Colors.green;
    if (effectiveness > 1) return Colors.lightGreen;
    if (effectiveness == 1) return Colors.grey;
    if (effectiveness > 0) return Colors.red;
    return Colors.black;
  }
}