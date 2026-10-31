import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Puente con Android: preferencias, abrir enlaces y compartir.
class Native {
  static const channel = MethodChannel('app/native');

  static Future<Map<String, dynamic>> prefs() async =>
      (await channel.invokeMapMethod<String, dynamic>('getPrefs')) ?? {};

  static Future<void> setBool(String k, bool v) =>
      channel.invokeMethod('setBool', {'key': k, 'value': v});

  static Future<void> setString(String k, String v) =>
      channel.invokeMethod('setString', {'key': k, 'value': v});

  static Future<bool> openUrl(String url) async =>
      (await channel.invokeMethod<bool>('openUrl', {'url': url})) ?? false;

  static Future<void> share(String text) =>
      channel.invokeMethod('share', {'text': text});
}

/// Estado global sencillo: tema, aceptación del aviso legal y promo.
class AppState extends ChangeNotifier {
  static const termsVersion = '1';

  bool loaded = false;
  ThemeMode themeMode = ThemeMode.system;
  bool termsAccepted = false;
  int promoHiddenUntil = 0;
  String appVersion = '';

  Future<void> load() async {
    try {
      final p = await Native.prefs();
      themeMode = switch (p['themeMode']) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      termsAccepted = p['termsAccepted'] == termsVersion;
      promoHiddenUntil = int.tryParse('${p['promoHiddenUntil'] ?? 0}') ?? 0;
      appVersion = (p['appVersion'] ?? '') as String;
    } catch (_) {}
    loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    notifyListeners();
    await Native.setString('themeMode', m.name);
  }

  Future<void> acceptTerms() async {
    termsAccepted = true;
    notifyListeners();
    await Native.setString('termsAccepted', termsVersion);
  }

  bool get showPromo => DateTime.now().millisecondsSinceEpoch > promoHiddenUntil;

  Future<void> hidePromo() async {
    promoHiddenUntil =
        DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
    notifyListeners();
    await Native.setString('promoHiddenUntil', '$promoHiddenUntil');
  }
}

/// Acceso al estado desde cualquier widget.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Para usar en callbacks (no se suscribe a cambios).
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
