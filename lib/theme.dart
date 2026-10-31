import 'package:flutter/material.dart';

class AppColors {
  static const seed = Color(0xFF0F766E);
  static const brand = Color(0xFF14917F);
  static const brandDeep = Color(0xFF0B4F48);
}

Color pageBg(Brightness b) =>
    b == Brightness.light ? const Color(0xFFF5F8F7) : const Color(0xFF0E1513);

ThemeData buildTheme(Brightness b) {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: b);
  final light = b == Brightness.light;
  final base =
      ThemeData(colorScheme: scheme, useMaterial3: true, fontFamily: 'Inter');
  final bg = pageBg(b);
  const btnText =
      TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16);

  return base.copyWith(
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700, color: scheme.onSurface, fontSize: 20),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: light ? Colors.white : scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant.withAlpha(110)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: btnText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: btnText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: btnText.copyWith(fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: light ? const Color(0xFFF0F4F3) : scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: light ? Colors.white : scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(const TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600)),
    ),
    switchTheme: SwitchThemeData(
      thumbIcon: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? const Icon(Icons.check, size: 16) : null),
    ),
    dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withAlpha(110), space: 1, thickness: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

class InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool warning;
  final Widget? action;

  const InfoBox(
      {super.key,
      required this.icon,
      required this.text,
      this.warning = false,
      this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = warning ? cs.tertiaryContainer : cs.secondaryContainer;
    final fg = warning ? cs.onTertiaryContainer : cs.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(text,
                      style: TextStyle(color: fg, height: 1.4, fontSize: 14))),
            ],
          ),
          if (action != null)
            Padding(
                padding: const EdgeInsets.only(left: 22, top: 4),
                child: action),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: .2)),
      );
}

/// Ícono dentro de un cuadro redondeado con color suave.
class IconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  const IconTile(this.icon, {super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(size * .32)),
      child: Icon(icon, color: cs.onPrimaryContainer, size: size * .52),
    );
  }
}
