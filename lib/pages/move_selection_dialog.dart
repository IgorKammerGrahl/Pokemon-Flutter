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
  late List<Move> _selectedMoves;

  @override
  void initState() {
    super.initState();
    _selectedMoves = List.from(widget.initialSelection);
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Movimentos (Max 4)'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.availableMoves.isEmpty
            ? const Text('Nenhum movimento disponível')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableMoves.length,
                itemBuilder: (context, index) {
                  final move = widget.availableMoves[index];
                  return CheckboxListTile(
                    title: Text('${move.name} (PP: ${move.pp})'),
                    value: _selectedMoves.contains(move),
                    onChanged: (value) => _toggleMove(move),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedMoves),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}