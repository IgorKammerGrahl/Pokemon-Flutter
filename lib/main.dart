import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/explore_page.dart';
import 'pages/team_page.dart';
import 'pages/battle_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Battle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pokemon', // Adicione a fonte baixada em pubspec.yaml
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
    BattlePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Meu Time'),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Batalha'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}