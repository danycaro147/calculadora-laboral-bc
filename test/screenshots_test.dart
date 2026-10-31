// Capturas para la Play Store: flutter test --update-goldens test/screenshots_test.dart
import 'dart:io';

import 'package:calculadora_laboral/app_state.dart';
import 'package:calculadora_laboral/calc.dart';
import 'package:calculadora_laboral/calc_screens.dart';
import 'package:calculadora_laboral/home.dart';
import 'package:calculadora_laboral/law.dart';
import 'package:calculadora_laboral/law_screens.dart';
import 'package:calculadora_laboral/main.dart';
import 'package:calculadora_laboral/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadFonts() async {
  final l = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    l.addFont(rootBundle.load('assets/fonts/Inter-$w.otf'));
  }
  await l.load();
  await (FontLoader('Lora')
        ..addFont(rootBundle.load('assets/fonts/Lora-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Lora-SemiBold.ttf')))
      .load();
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final f = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (f.existsSync()) {
      await (FontLoader('MaterialIcons')
            ..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync()))))
          .load();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Ley ley;

  setUpAll(() async {
    await loadFonts();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(Native.channel, (call) async {
      if (call.method == 'getPrefs') {
        return {'termsAccepted': '1', 'appVersion': '1.0.0'};
      }
      return null;
    });
  });

  Future<void> shoot(WidgetTester tester, String name, Widget home,
      {ThemeMode mode = ThemeMode.light, String? scrollTo}) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    debugDisableShadows = false;

    final state = AppState();
    await tester.runAsync(() async {
      await state.load();
      ley = await LeyRepo.cargar();
    });
    state.themeMode = mode;
    await tester.pumpWidget(CalculadoraApp(state: state, debugHome: home));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(Scaffold).first);
      await precacheImage(const AssetImage('assets/images/braincode_isotipo.png'), ctx);
    });
    await tester.pumpAndSettle();
    if (scrollTo != null) {
      await tester.scrollUntilVisible(find.text(scrollTo), 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
    }
    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('../store/screenshots/$name.png'));
    debugDisableShadows = true;
  }

  final r = calcularSalida(SalidaDatos(
      salarioDiario: 600,
      ingreso: DateTime(2019, 3, 4),
      salida: DateTime(2026, 10, 15),
      diasSalarioPendiente: 10,
      despido: true));

  testWidgets('01 bienvenida', (t) => shoot(t, '01_bienvenida', const WelcomeScreen()));
  testWidgets('02 inicio', (t) => shoot(t, '02_inicio', const HomeShell()));
  testWidgets('03 formulario',
      (t) => shoot(t, '03_formulario', const CalcFormScreen(tipo: TipoCalculo.liquidacion)));
  testWidgets('04 resultado', (t) => shoot(t, '04_resultado',
      ResultScreen(tipo: TipoCalculo.liquidacion, resultado: r, salarioDiario: 600, antiguedad: 7.62)));
  testWidgets('05 ley', (t) => shoot(t, '05_ley', const HomeShell(initialTab: 1)));
  testWidgets('06 articulo', (t) async {
    await t.runAsync(() async => ley = await LeyRepo.cargar());
    await shoot(t, '06_articulo', ArticleScreen(ley: ley, index: ley.indice('87')!));
  });
  testWidgets('07 oscuro',
      (t) => shoot(t, '07_inicio_oscuro', const HomeShell(), mode: ThemeMode.dark));
  testWidgets('08 ajustes', (t) => shoot(t, '08_ajustes', const HomeShell(initialTab: 2)));
  testWidgets('09 resultado oscuro', (t) => shoot(t, '09_resultado_oscuro',
      ResultScreen(tipo: TipoCalculo.liquidacion, resultado: r, salarioDiario: 600, antiguedad: 7.62),
      mode: ThemeMode.dark));
}
