import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_tcg/main.dart';
import 'package:projeto_tcg/pages/splash_screen.dart';

void main() {
  testWidgets('Teste inicial do app', (WidgetTester tester) async {
    // Build do app sem usar "const"
    await tester.pumpWidget(MyApp()); // Remova o "const" aqui

    // Verifique se a SplashScreen é exibida inicialmente
    expect(find.byType(SplashScreen), findsOneWidget);

    // Aguarde a navegação automática para a HomePage
    await tester.pumpAndSettle();

    // Verifique se a BottomNavigationBar está presente
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}