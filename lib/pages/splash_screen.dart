import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Navega para a HomePage após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.primary,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _controller,
            child: Image.asset('assets/pokeball.png', width: 100),
          ),
          SizedBox(height: 20),
          Text( // <--- Texto de teste
            'Pokémon',
            style: AppTextStyles.pokemonTitle,
          ),
        ],
      ),
    ),
  );
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}