import 'package:flutter/material.dart';

/// Sistema visual sobrio (legal / financiero): azul tinta + grises neutros.
class Tok {
  final Color bg, surface, surface2, border, text, text2, text3;
  final Color primary, onPrimary, primarySoft, accent;
  final Color noticeBg, noticeBorder, noticeText;

  const Tok._({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.text2,
    required this.text3,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.accent,
    required this.noticeBg,
    required this.noticeBorder,
    required this.noticeText,
  });

  static const light = Tok._(
    bg: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1F3F6),
    border: Color(0xFFE2E5EA),
    text: Color(0xFF0E1726),
    text2: Color(0xFF545E6E),
    text3: Color(0xFF8A93A1),
    primary: Color(0xFF0F2A4A),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE9EEF5),
    accent: Color(0xFFB4884B),
    noticeBg: Color(0xFFFBF7EF),
    noticeBorder: Color(0xFFEAD9B8),
    noticeText: Color(0xFF5C4416),
  );

  static const dark = Tok._(
    bg: Color(0xFF0B0F14),
    surface: Color(0xFF12171E),
    surface2: Color(0xFF1A2029),
    border: Color(0xFF263040),
    text: Color(0xFFE8ECF2),
    text2: Color(0xFFA3ADBB),
    text3: Color(0xFF6F7A8A),
    primary: Color(0xFF9DBCE8),
    onPrimary: Color(0xFF0B1626),
    primarySoft: Color(0xFF17243A),
    accent: Color(0xFFD2A869),
    noticeBg: Color(0xFF1E1A12),
    noticeBorder: Color(0xFF3F3420),
    noticeText: Color(0xFFE4C891),
  );

  static Tok of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

const kRadius = 12.0;
const kSerif = 'Lora';

ThemeData buildTheme(Brightness b) {
  final t = b == Brightness.dark ? Tok.dark : Tok.light;
  final scheme = ColorScheme(
    brightness: b,
    primary: t.primary,
    onPrimary: t.onPrimary,
    secondary: t.primary,
    onSecondary: t.onPrimary,
    error: const Color(0xFFB42318),
    onError: Colors.white,
    surface: t.surface,
    onSurface: t.text,
    onSurfaceVariant: t.text2,
    outline: t.text3,
    outlineVariant: t.border,
    primaryContainer: t.primarySoft,
    onPrimaryContainer: t.primary,
    secondaryContainer: t.primarySoft,
    onSecondaryContainer: t.primary,
    surfaceContainerLowest: t.surface,
    surfaceContainerLow: t.surface,
    surfaceContainer: t.surface2,
    surfaceContainerHigh: t.surface2,
    surfaceContainerHighest: t.surface2,
  );
  final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: 'Inter',
      splashFactory: InkRipple.splashFactory);
  final tt = base.textTheme.apply(bodyColor: t.text, displayColor: t.text);
  final r = BorderRadius.circular(kRadius);
  const btn = TextStyle(
      fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: .1);

  return base.copyWith(
    scaffoldBackgroundColor: t.bg,
    textTheme: tt,
    appBarTheme: AppBarTheme(
      backgroundColor: t.bg,
      foregroundColor: t.text,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      titleTextStyle: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w700, fontSize: 19, letterSpacing: -.2),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: t.surface,
      shape: RoundedRectangleBorder(
          borderRadius: r, side: BorderSide(color: t.border)),
      clipBehavior: Clip.antiAlias,
    ),
    dividerTheme: DividerThemeData(color: t.border, space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        backgroundColor: t.primary,
        foregroundColor: t.onPrimary,
        disabledBackgroundColor: t.border,
        disabledForegroundColor: t.text3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: btn,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        foregroundColor: t.text,
        side: BorderSide(color: t.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: btn,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.primary,
        minimumSize: const Size(48, 44),
        textStyle: btn.copyWith(fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surface,
      hintStyle: TextStyle(color: t.text3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: t.primary, width: 1.6)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error, width: 1.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      height: 64,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? t.primary : t.text3, size: 24)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? t.primary : t.text3)),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: t.text2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      titleTextStyle: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: t.text),
      subtitleTextStyle: tt.bodyMedium?.copyWith(color: t.text2),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.onPrimary : t.text3),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.primary : t.surface2),
      trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.primary : t.border),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.primary : Colors.transparent),
      checkColor: WidgetStatePropertyAll(t.onPrimary),
      side: BorderSide(color: t.text3, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: t.surface,
      side: BorderSide(color: t.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: t.text),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: t.text,
      contentTextStyle: TextStyle(fontFamily: 'Inter', color: t.bg),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: t.primary,
      headerForegroundColor: t.onPrimary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

// ---------------------------------------------------------------------------
// Componentes base
// ---------------------------------------------------------------------------

/// Encabezado de sección en versalitas.
class SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  const SectionTitle(this.text,
      {super.key, this.padding = const EdgeInsets.fromLTRB(4, 28, 4, 10)});

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: Tok.of(context).text3)),
      );
}

/// Barra inferior fija para las acciones principales de una pantalla.
class BottomActionBar extends StatelessWidget {
  final List<Widget> children;
  final Widget? top;
  const BottomActionBar({super.key, required this.children, this.top});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (top != null) top!,
              Row(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: children[i]),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aviso con borde (legal / informativo).
class Notice extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? title;
  final bool legal;
  final Widget? action;
  const Notice(
      {super.key,
      required this.icon,
      required this.text,
      this.title,
      this.legal = false,
      this.action});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final bg = legal ? t.noticeBg : t.surface2;
    final bd = legal ? t.noticeBorder : t.border;
    final fg = legal ? t.noticeText : t.text2;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: bd)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(title!,
                        style: TextStyle(
                            color: fg, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                Text(text,
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: fg, height: 1.45, fontSize: 13.5)),
                if (action != null) action!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Párrafo justificado estándar.
class Para extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  const Para(this.text, {super.key, this.size = 15, this.color});

  @override
  Widget build(BuildContext context) => Text(text,
      textAlign: TextAlign.justify,
      style: TextStyle(
          fontSize: size, height: 1.5, color: color ?? Tok.of(context).text2));
}

/// Fila de lista tipo "ajustes": ícono de línea, título, subtítulo y chevron.
class RowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final Widget? trailing;
  const RowTile(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle,
      this.trailingText,
      this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Icon(icon, color: t.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600, color: t.text)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: TextStyle(fontSize: 14, color: t.text2, height: 1.35)),
                  ],
                ],
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(trailingText!,
                    style: TextStyle(
                        fontSize: 12.5, color: t.text3, fontWeight: FontWeight.w600)),
              ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right_rounded, color: t.text3)
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta con filas separadas por divisores.
class GroupCard extends StatelessWidget {
  final List<Widget> children;
  final double indent;
  const GroupCard({super.key, required this.children, this.indent = 54});

  @override
  Widget build(BuildContext context) => Card(
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) Divider(indent: indent),
              children[i],
            ],
          ],
        ),
      );
}

/// Marca de la app: cuadro azul tinta con el ícono de calculadora.
class AppMark extends StatelessWidget {
  final double size;
  const AppMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0F2A4A),
          borderRadius: BorderRadius.circular(size * .24),
        ),
        child: Icon(Icons.request_quote, color: Colors.white, size: size * .56),
      );
}
