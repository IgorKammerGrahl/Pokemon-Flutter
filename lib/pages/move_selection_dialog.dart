import 'package:flutter/material.dart';
import '../battle/models/move.dart';

class MoveSelectionDialog extends StatefulWidget {
  final List<Move> availableMoves;
  final List<Move> initialSelection;

  const MoveSelectionDialog({
    super.key,
    required this.availableMoves,
    required this.initialSelection,
  });

  @override
  State<MoveSelectionDialog> createState() => _MoveSelectionDialogState();
}

class _MoveSelectionDialogState extends State<MoveSelectionDialog> {
  List<Move> _selectedMoves = [];

  @override
  void initState() {
    super.initState();
    _selectedMoves = List.from(widget.initialSelection);
  }

  Color _getTypeColor(String type) {
    // Use a mesma função de cores dos Pokémon
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

    @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione Movimentos (Max 4)', style: TextStyle(fontSize: 18)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, // 90% da tela
        child: ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: widget.availableMoves.length,
          itemBuilder: (context, index) {
            final move = widget.availableMoves[index];
            final isSelected = _selectedMoves.contains(move);
            final typeColor = _getTypeColor(move.type);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    typeColor.withOpacity(isSelected ? 0.15 : 0.08),
                    typeColor.withOpacity(isSelected ? 0.08 : 0.03),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _toggleMove(move),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ícone de seleção
                      Icon(
                        isSelected 
                            ? Icons.check_box_rounded 
                            : Icons.check_box_outline_blank,
                        color: typeColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),

                      // Detalhes do movimento
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome e Tipo
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    move.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: typeColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    move.type,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Status
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildStatItem('PODER', move.power.toString()),
                                  _buildStatItem('PREÇ.', '${move.accuracy}%'),
                                  _buildStatItem('PP', move.pp.toString()),
                                  _buildStatItem('CLASSE', move.damageClass),
                                ].map((widget) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: widget,
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () => Navigator.pop(context, _selectedMoves),
          child: const Text('Confirmar', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _toggleMove(Move move) {
    setState(() {
      if (_selectedMoves.contains(move)) {
        _selectedMoves.remove(move);
      } else if (_selectedMoves.length < 4) {
        _selectedMoves.add(move);
      }
    });
  }
}