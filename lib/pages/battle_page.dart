import 'package:flutter/material.dart';
import '../battle/models/battle_pokemon.dart';
import '../battle/models/move.dart';
import '../battle/services/battle_calculator.dart';
import 'dart:math';

class BattlePage extends StatefulWidget {
  final BattlePokemon playerPokemon;
  final BattlePokemon enemyPokemon;

  const BattlePage({
    super.key,
    required this.playerPokemon,
    required this.enemyPokemon,
  });

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _playerAnimation;
  late Animation<double> _enemyAnimation;
  bool _showMoveSelection = false;
  String _battleMessage = '';
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _playerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _enemyAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _controller.forward();
    _showInitialMessage();
  }

  void _showInitialMessage() {
    setState(() {
      _battleMessage = 'Wild ${widget.enemyPokemon.basePokemon.name} appeared!';
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _battleMessage = 'Go ${widget.playerPokemon.basePokemon.name}!';
      });
    });
  }
  void _attack(Move move) async {
    setState(() {
      _showMoveSelection = false;
      _battleMessage = '${widget.playerPokemon.basePokemon.name} used ${move.name}!';
    });

    // Animação de ataque
    _controller.reset();
    await _controller.forward();

    // Cálculo real de dano
    final damage = await BattleCalculator.calculateDamage(
      attacker: widget.playerPokemon,
      defender: widget.enemyPokemon,
      move: move,
    );

    // Animação de dano
    _shakePokemon(widget.enemyPokemon);
    widget.enemyPokemon.takeDamage(damage);
    
    setState(() {});
    
    // Verificar derrota do inimigo
    if (widget.enemyPokemon.currentHp <= 0) {
      _showVictoryMessage();
      return;
    }

    // Ataque do inimigo com delay
    Future.delayed(const Duration(seconds: 2), _enemyAttack);
  }

  void _enemyAttack() async {
    setState(() {
      _battleMessage = 'Enemy ${widget.enemyPokemon.basePokemon.name} attacks!';
    });

    // Animação de ataque inimigo
    _controller.reset();
    await _controller.forward();

    // Selecionar movimento aleatório do inimigo
    final randomMove = widget.enemyPokemon.moves[
      Random().nextInt(widget.enemyPokemon.moves.length)
    ];

    // Cálculo real de dano
    final damage = await BattleCalculator.calculateDamage(
      attacker: widget.enemyPokemon,
      defender: widget.playerPokemon,
      move: randomMove,
    );

    setState(() {
      _battleMessage = 'Enemy ${widget.enemyPokemon.basePokemon.name} used ${randomMove.name}!';
    });

    // Animação de dano
    _shakePokemon(widget.playerPokemon);
    widget.playerPokemon.takeDamage(damage);
    
    setState(() {});
    
    // Verificar derrota do jogador
    if (widget.playerPokemon.currentHp <= 0) {
      _showDefeatMessage();
      return;
    }

    // Habilitar seleção de movimento novamente
    setState(() {
      _showMoveSelection = true;
    });
  }

 void _shakePokemon(BattlePokemon pokemon) {
  final shakeController = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  )..repeat(reverse: true);
  
  final shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
    CurvedAnimation(parent: shakeController, curve: Curves.easeInOut),
  );

  shakeAnimation.addListener(() {
    setState(() {});
  });

  shakeController.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      shakeController.dispose();
    }
  });

  shakeController.forward();
}

  void _showVictoryMessage() {
    setState(() {
      _battleMessage = 'You won the battle!';
    });
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  void _showDefeatMessage() {
    setState(() {
      _battleMessage = 'You were defeated...';
    });
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF78C850), Color(0xFF98D8D8)],
              ),
            ),
          ),
          
          // Pokémon Inimigo
          Align(
            alignment: const Alignment(0, -0.4),
            child: AnimatedBuilder(
              animation: _enemyAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _enemyAnimation.value)),
                  child: Opacity(
                    opacity: _enemyAnimation.value,
                    child: Image.network(
                      widget.enemyPokemon.basePokemon.imageUrl,
                      height: 120,
                    ),
                  ),
                );
              },
            ),
          ),

          // Pokémon Jogador
          Align(
            alignment: const Alignment(0, 0.4),
            child: AnimatedBuilder(
              animation: _playerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _playerAnimation.value)),
                  child: Opacity(
                    opacity: _playerAnimation.value,
                    child: Image.network(
                      widget.playerPokemon.basePokemon.imageUrl,
                      height: 150,
                    ),
                  ),
                );
              },
            ),
          ),

          // Barra de status do inimigo
          Positioned(
            top: 40,
            left: 20,
            child: _buildStatusBar(widget.enemyPokemon),
          ),

          // Barra de status do jogador
          Positioned(
            bottom: 140,
            right: 20,
            child: _buildStatusBar(widget.playerPokemon),
          ),

          // Mensagem de batalha
          Positioned(
            bottom: _showMoveSelection ? 200 : 80,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _battleMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Seleção de movimentos
          if (_showMoveSelection)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildMoveSelection(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BattlePokemon pokemon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pokemon.basePokemon.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                width: 100,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: (pokemon.currentHp / pokemon.calculateStat('hp')) * 100,
                height: 8,
                decoration: BoxDecoration(
                  color: _getHealthBarColor(pokemon.currentHp / pokemon.calculateStat('hp')),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHealthBarColor(double ratio) {
    if (ratio > 0.5) return Colors.green;
    if (ratio > 0.2) return Colors.yellow;
    return Colors.red;
  }

  Widget _buildMoveSelection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: widget.playerPokemon.moves.length,
      itemBuilder: (context, index) {
        final move = widget.playerPokemon.moves[index];
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _getMoveColor(move.type),
            foregroundColor: Colors.white,
          ),
          onPressed: () => _attack(move),
          child: Text(
            move.name,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Color _getMoveColor(String type) {
    const typeColors = {
      'fire': Colors.orange,
      'water': Colors.blue,
      'grass': Colors.green,
      'electric': Colors.yellow,
      'psychic': Colors.purple,
    };
    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}