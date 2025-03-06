import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/explore_page.dart';
import 'pages/team_page.dart';
import 'pages/battle_page.dart';
import 'models/pokemon.dart';
import '../battle/models/battle_pokemon.dart';
import '../battle/models/move.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Battle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pokemon',
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ExplorePage(),
    TeamPage(),
    BattlePage(
      playerPokemon: _createTempPokemon(), 
      enemyPokemon: _createTempPokemon(isEnemy: true),
    ),
  ];

  static BattlePokemon _createTempPokemon({bool isEnemy = false}) {
  return BattlePokemon.fromBase(
    Pokemon( // Parâmetro posicional sem nome
      name: isEnemy ? 'Charizard' : 'Blastoise',
      id: isEnemy ? 6 : 9,
      types: isEnemy ? ['Fire'] : ['Water'],
      imageUrl: isEnemy 
          ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png'
          : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/9.png',
      stats: [
        const Stat(name: 'hp', value: 100),
        const Stat(name: 'attack', value: 80),
        const Stat(name: 'defense', value: 70),
        const Stat(name: 'special-attack', value: 90),
        const Stat(name: 'special-defense', value: 85),
        const Stat(name: 'speed', value: 75),
      ],
    ),
    moves: [ // Parâmetro nomeado
      Move(
        name: isEnemy ? 'Flamethrower' : 'Hydro Pump',
        power: isEnemy ? 90 : 110,
        accuracy: isEnemy ? 100 : 80,
        type: isEnemy ? 'Fire' : 'Water',
        pp: 15,
        damageClass: 'special',
      ),
      Move(
        name: isEnemy ? 'Dragon Claw' : 'Ice Beam',
        power: isEnemy ? 80 : 90,
        accuracy: 100,
        type: isEnemy ? 'Dragon' : 'Ice',
        pp: 10,
        damageClass: 'physical',
      ),
    ],
    level: 50,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Meu Time'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Batalha'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}