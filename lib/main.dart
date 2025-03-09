import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/splash_screen.dart';
import 'pages/explore_page.dart';
import 'pages/team_builder_page.dart';
import 'pages/battle_page.dart';
import 'models/pokemon.dart';
import 'battle/models/battle_pokemon.dart';
import 'battle/models/move.dart';
import 'services/storage_service.dart';
import '../providers/pokemon_provider.dart';
import '../providers/team_provider.dart';


void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TeamProvider()),
      ChangeNotifierProvider(create: (_) => PokemonProvider()),
    ],
    child: const MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Battle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pokemon',
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case '/home':
                return const HomePage();
              case '/team':
                return TeamBuilderPage(
                  availablePokemons: Provider.of<PokemonProvider>(context).availablePokemons,
                );
              default:
                return const SplashScreen();
            }
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadTeam();
    _loadPokemons();
  }

  void _loadTeam() async {
    final team = await StorageService.getTeam();
    Provider.of<TeamProvider>(context, listen: false).setTeam(team);
  }

  void _loadPokemons() async {
  try {
    await Provider.of<PokemonProvider>(context, listen: false).loadPokemons();
  } catch (e) {
    debugPrint("Erro ao carregar Pokémon: ${e.toString()}");
  }
}

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final pokemonProvider = Provider.of<PokemonProvider>(context);

    _pages = [
      const ExplorePage(),
      TeamBuilderPage(
        availablePokemons: pokemonProvider.availablePokemons,
      ),
      BattlePage(
        playerTeam: teamProvider.team,
        enemyTeam: _createRivalTeam(),
      ),
    ];

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
  List<BattlePokemon> _createRivalTeam() {
    return [
      _createRivalPokemon(
        name: 'Charizard',
        types: ['Fire', 'Flying'],
        imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png',
        moves: [
          Move(
            name: 'Flamethrower',
            power: 90,
            accuracy: 100,
            type: 'Fire',
            pp: 15,
            damageClass: 'special',
          ),
          Move(
            name: 'Dragon Claw',
            power: 80,
            accuracy: 100,
            type: 'Dragon',
            pp: 15,
            damageClass: 'physical',
          ),
        ],
      ),
    ];
  }

  BattlePokemon _createRivalPokemon({
    required String name,
    required List<String> types,
    required String imageUrl,
    required List<Move> moves,
  }) {
    return BattlePokemon.fromBase(
      Pokemon(
        name: name,
        id: 6, // ID do Charizard
        types: types,
        imageUrl: imageUrl,
        stats: [
          const Stat(name: 'hp', value: 78),
          const Stat(name: 'attack', value: 84),
          const Stat(name: 'defense', value: 78),
          const Stat(name: 'special-attack', value: 109),
          const Stat(name: 'special-defense', value: 85),
          const Stat(name: 'speed', value: 100),
        ],
        learnableMoves: moves,
      ),
      moves: moves,
      level: 50,
    );
  }
}
