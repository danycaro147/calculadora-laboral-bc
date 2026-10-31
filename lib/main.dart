// © 2026 BrainCode México Tech. Todos los derechos reservados.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'home.dart';
import 'law.dart';
import 'theme.dart';
import 'welcome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState()..load();
  LeyRepo.cargar(); // precarga la ley en segundo plano
  runApp(CalculadoraApp(state: state));
}

class CalculadoraApp extends StatelessWidget {
  final AppState state;

  /// Solo para capturas/pruebas.
  final Widget? debugHome;

  const CalculadoraApp({super.key, required this.state, this.debugHome});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'Calculadora Laboral',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: state.themeMode,
          locale: const Locale('es', 'MX'),
          supportedLocales: const [Locale('es', 'MX'), Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: debugHome ??
              (!state.loaded
                  ? const Scaffold(body: SizedBox())
                  : state.termsAccepted
                      ? const HomeShell()
                      : const WelcomeScreen()),
        ),
      ),
    );
  }
}
