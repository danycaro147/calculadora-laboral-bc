import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/services.dart';

/// Sistema visual sobrio: neutros tinta/grafito, un solo acento (zafiro),
/// superficies de vidrio discretas y un fondo con brillo tenue en movimiento.
class Tok {
  final Color bg, surface, surface2, border, text, text2, text3;
  final Color primary, onPrimary, primarySoft, accent;
  final Color noticeBg, noticeBorder, noticeText;
  final Color shadow, glass, glassEdge;
  final Color ink, onInk;
  final List<Color> glow;

  /// Tonos del acento, de más a menos intenso, para gráficas.
  final List<Color> ramp;

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
    required this.shadow,
    required this.glass,
    required this.glassEdge,
    required this.ink,
    required this.onInk,
    required this.glow,
    required this.ramp,
  });

  static const light = Tok._(
    bg: Color(0xFFF4F5F8),
    surface: Color(0xD9FFFFFF),
    surface2: Color(0xFFEDEFF3),
    border: Color(0xFFE2E5EB),
    text: Color(0xFF0E1117),
    text2: Color(0xFF4A5261),
    text3: Color(0xFF858D9C),
    primary: Brand.accent,
    onPrimary: Colors.white,
    primarySoft: Color(0xFFE8EDFD),
    accent: Brand.accent,
    noticeBg: Color(0xCCFFFFFF),
    noticeBorder: Color(0xFFE2E5EB),
    noticeText: Color(0xFF4A5261),
    shadow: Color(0x140E1424),
    glass: Color(0xCCFFFFFF),
    glassEdge: Color(0xFFFFFFFF),
    ink: Brand.ink,
    onInk: Colors.white,
    glow: [Color(0xFFB9C8F7), Color(0xFFD6DCEA)],
    ramp: [
      Color(0xFF0E1424),
      Color(0xFF1E3A8A),
      Color(0xFF2952E3),
      Color(0xFF6584EE),
      Color(0xFF9FB2F4),
      Color(0xFFC9D4F9),
    ],
  );

  static const dark = Tok._(
    bg: Color(0xFF090B10),
    surface: Color(0x14FFFFFF),
    surface2: Color(0xFF161A22),
    border: Color(0x1FFFFFFF),
    text: Color(0xFFEEF0F4),
    text2: Color(0xFFA3AAB8),
    text3: Color(0xFF6E7685),
    primary: Color(0xFF8EA6F6),
    onPrimary: Color(0xFF0B1022),
    primarySoft: Color(0x262952E3),
    accent: Color(0xFF8EA6F6),
    noticeBg: Color(0x0FFFFFFF),
    noticeBorder: Color(0x1FFFFFFF),
    noticeText: Color(0xFFA3AAB8),
    shadow: Color(0x66000000),
    glass: Color(0x12FFFFFF),
    glassEdge: Color(0x2EFFFFFF),
    ink: Color(0xFFF2F4F8),
    onInk: Color(0xFF0B0F1A),
    glow: [Color(0xFF1C3488), Color(0xFF1A2236)],
    ramp: [
      Color(0xFFE8EDFD),
      Color(0xFFB4C3F8),
      Color(0xFF8EA6F6),
      Color(0xFF5677E9),
      Color(0xFF3553C4),
      Color(0xFF26387F),
    ],
  );

  static Tok of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}

/// Colores de marca.
class Brand {
  static const accent = Color(0xFF2952E3);
  static const ink = Color(0xFF0E1424);
  static const ink2 = Color(0xFF1A2440);
}

/// Interruptor global de animaciones continuas (se apaga en pruebas/capturas).
class Motion {
  static bool enabled = true;
  static bool on(BuildContext context) =>
      enabled && !MediaQuery.of(context).disableAnimations;
}

const kRadius = 20.0;
const kSerif = 'Lora';

ThemeData buildTheme(Brightness b) {
  final t = b == Brightness.dark ? Tok.dark : Tok.light;
  final dark = b == Brightness.dark;
  final scheme = ColorScheme(
    brightness: b,
    primary: t.primary,
    onPrimary: t.onPrimary,
    secondary: t.primary,
    onSecondary: t.onPrimary,
    error: const Color(0xFFD14343),
    onError: Colors.white,
    surface: dark ? const Color(0xFF12151C) : Colors.white,
    onSurface: t.text,
    onSurfaceVariant: t.text2,
    outline: t.text3,
    outlineVariant: t.border,
    primaryContainer: t.primarySoft,
    onPrimaryContainer: t.primary,
    secondaryContainer: t.primarySoft,
    onSecondaryContainer: t.primary,
  );
  final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: 'Inter',
      splashFactory: InkRipple.splashFactory);
  final tt = base.textTheme.apply(bodyColor: t.text, displayColor: t.text);
  const btnR = BorderRadius.all(Radius.circular(14));
  const btn = TextStyle(
      fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: .1);

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: tt,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: _FadeSlideTransitions(),
      TargetPlatform.iOS: _FadeSlideTransitions(),
    }),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: t.text,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      systemOverlayStyle: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
          fontFamily: kSerif, fontWeight: FontWeight.w600, fontSize: 21, color: t.text),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: t.glass,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius), side: BorderSide(color: t.border)),
      clipBehavior: Clip.antiAlias,
    ),
    dividerTheme: DividerThemeData(color: t.border, space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 54),
        backgroundColor: t.ink,
        foregroundColor: t.onInk,
        disabledBackgroundColor: dark ? const Color(0x1AFFFFFF) : const Color(0xFFE4E7EC),
        disabledForegroundColor: t.text3,
        shape: const RoundedRectangleBorder(borderRadius: btnR),
        textStyle: btn,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 54),
        foregroundColor: t.text,
        backgroundColor: t.glass,
        side: BorderSide(color: t.border),
        shape: const RoundedRectangleBorder(borderRadius: btnR),
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
      fillColor: t.glass,
      hintStyle: TextStyle(color: t.text3),
      border: OutlineInputBorder(borderRadius: btnR, borderSide: BorderSide(color: t.border)),
      enabledBorder:
          OutlineInputBorder(borderRadius: btnR, borderSide: BorderSide(color: t.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: btnR, borderSide: BorderSide(color: t.primary, width: 1.6)),
      errorBorder:
          OutlineInputBorder(borderRadius: btnR, borderSide: BorderSide(color: scheme.error)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: btnR, borderSide: BorderSide(color: scheme.error, width: 1.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: t.text2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      titleTextStyle: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: t.text),
      subtitleTextStyle: tt.bodyMedium?.copyWith(color: t.text2),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : t.text3),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Brand.accent : t.surface2),
      trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Brand.accent : t.border),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Brand.accent : Colors.transparent),
      checkColor: const WidgetStatePropertyAll(Colors.white),
      side: BorderSide(color: t.text3, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? const Color(0xFF1B1F29) : Brand.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(fontFamily: 'Inter', color: Colors.white),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: Brand.ink,
      headerForegroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}

/// Transición: la nueva pantalla aparece y sube ligeramente.
class _FadeSlideTransitions extends PageTransitionsBuilder {
  const _FadeSlideTransitions();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> a,
      Animation<double> s, Widget child) {
    final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: c,
      child: SlideTransition(
          position: Tween(begin: const Offset(0, .03), end: Offset.zero).animate(c),
          child: child),
    );
  }
}

List<BoxShadow> softShadow(BuildContext context, {double y = 8, double blur = 24}) => [
      BoxShadow(
          color: Tok.of(context).shadow,
          blurRadius: blur,
          offset: Offset(0, y),
          spreadRadius: -6),
    ];

// ---------------------------------------------------------------------------
// Fondo
// ---------------------------------------------------------------------------

/// Pantalla con fondo de brillo tenue en movimiento. Sustituye a [Scaffold].
class GlassScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  const GlassScaffold({super.key, this.appBar, this.body, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    final dark = Tok.isDark(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(systemNavigationBarColor: Colors.transparent),
      child: MeshBackground(
        child: BackdropGroup(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            // Sin barra inferior propia, el contenido no debe quedar bajo la barra
            // de navegación del sistema (botones o gestos).
            body: bottomNavigationBar == null && body != null
                ? SafeArea(top: false, child: body!)
                : body,
            bottomNavigationBar: bottomNavigationBar,
          ),
        ),
      ),
    );
  }
}

class MeshBackground extends StatefulWidget {
  final Widget child;
  const MeshBackground({super.key, required this.child});

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 40));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.on(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = .15;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _GlowPainter(_c, Tok.of(context), Tok.isDark(context))),
          ),
          widget.child,
        ],
      );
}

/// Dos halos grandes y tenues que derivan lentamente.
class _GlowPainter extends CustomPainter {
  final Animation<double> a;
  final Tok t;
  final bool dark;
  _GlowPainter(this.a, this.t, this.dark) : super(repaint: a);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = t.bg);
    final w = size.width, h = size.height;
    final p = a.value * 2 * math.pi;
    final halos = [
      (Offset(w * (.85 + .08 * math.sin(p)), h * (.02 + .05 * math.cos(p))), w * 1.0,
          t.glow[0], dark ? 120 : 150),
      (Offset(w * (.05 + .08 * math.cos(p)), h * (.55 + .06 * math.sin(p))), w * .9,
          t.glow[1], dark ? 90 : 120),
    ];
    for (final (c, r, col, alpha) in halos) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(colors: [col.withAlpha(alpha), col.withAlpha(0)])
              .createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Vidrio
// ---------------------------------------------------------------------------

/// Superficie de vidrio discreta: desenfoque, relleno translúcido y borde fino.
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double blur;
  final bool shadow;
  const Glass(
      {super.key,
      required this.child,
      this.radius = kRadius,
      this.padding = EdgeInsets.zero,
      this.onTap,
      this.blur = 20,
      this.shadow = true});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final br = BorderRadius.circular(radius);
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
          type: MaterialType.transparency,
          child: InkWell(onTap: onTap, borderRadius: br, child: content));
    }
    return DecoratedBox(
      decoration:
          BoxDecoration(borderRadius: br, boxShadow: shadow ? softShadow(context) : null),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter.grouped(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.glass,
              borderRadius: br,
              border: Border.all(color: Tok.isDark(context) ? t.glassEdge : t.border),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Botón principal (tinta sólida) con ícono al final.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: onPressed,
        iconAlignment: IconAlignment.end,
        icon: icon == null ? null : Icon(icon, size: 20),
        label: Text(label),
      );
}

// ---------------------------------------------------------------------------
// Componentes base
// ---------------------------------------------------------------------------

/// Encabezado de sección.
class SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final Widget? trailing;
  const SectionTitle(this.text,
      {super.key, this.padding = const EdgeInsets.fromLTRB(4, 28, 4, 12), this.trailing});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(text.toUpperCase(),
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: t.text3)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Encabezado de paso numerado para formularios.
class StepTitle extends StatelessWidget {
  final int n;
  final String text;
  const StepTitle(this.n, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 14),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: t.primary, width: 1.5),
            ),
            child: Text('$n',
                style: TextStyle(color: t.primary, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Text(text,
              style: TextStyle(
                  fontFamily: kSerif, fontSize: 19, fontWeight: FontWeight.w600, color: t.text)),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: t.border)),
        ],
      ),
    );
  }
}

/// Barra inferior de vidrio, de borde a borde, para las acciones principales.
class BottomActionBar extends StatelessWidget {
  final List<Widget> children;
  final Widget? top;
  const BottomActionBar({super.key, required this.children, this.top});

  @override
  Widget build(BuildContext context) => _GlassBar(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (top != null) top!,
            Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: children[i]),
                ],
              ],
            ),
          ],
        ),
      );
}

class _GlassBar extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _GlassBar({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.glass,
            border: Border(top: BorderSide(color: t.border)),
          ),
          child: SafeArea(top: false, child: Padding(padding: padding, child: child)),
        ),
      ),
    );
  }
}

/// Aviso (legal / informativo).
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
    return Glass(
      shadow: false,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: t.text2),
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
                            color: t.text, fontWeight: FontWeight.w700, fontSize: 14.5)),
                  ),
                Text(text,
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: t.text2, height: 1.5, fontSize: 13.5)),
                if (action != null) action!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Párrafo estándar.
class Para extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  const Para(this.text, {super.key, this.size = 15, this.color});

  @override
  Widget build(BuildContext context) => Text(text,
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: size, height: 1.55, color: color ?? Tok.of(context).text2));
}

/// Ícono sobre un cuadro con tinte suave del acento (o tinta, si [solid]).
class IconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool solid;
  const IconTile(this.icon, {super.key, this.size = 42, this.solid = false});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: solid ? t.ink : t.primarySoft,
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: Icon(icon, size: size * .5, color: solid ? t.onInk : t.primary),
    );
  }
}

/// Fila de lista: ícono, título, subtítulo y chevron.
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
        padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
        child: Row(
          children: [
            IconTile(icon, size: 38),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w600, color: t.text)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: TextStyle(fontSize: 13.5, color: t.text2, height: 1.35)),
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
                    ? Icon(PhosphorIconsLight.caretRight, color: t.text3)
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de vidrio con filas separadas por divisores.
class GroupCard extends StatelessWidget {
  final List<Widget> children;
  final double indent;
  const GroupCard({super.key, required this.children, this.indent = 66});

  @override
  Widget build(BuildContext context) => Glass(
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(indent: indent, endIndent: 14),
                children[i],
              ],
            ],
          ),
        ),
      );
}

/// Marca de la app.
class AppMark extends StatelessWidget {
  final double size;
  const AppMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Brand.ink2, Brand.ink]),
          borderRadius: BorderRadius.circular(size * .28),
          border: Border.all(color: Colors.white.withAlpha(Tok.isDark(context) ? 40 : 0)),
        ),
        child: Icon(PhosphorIconsLight.receipt, color: Colors.white, size: size * .5),
      );
}

/// Panel destacado: vidrio con un halo tenue del acento en la esquina.
class HeroPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const HeroPanel({super.key, required this.child, this.padding = const EdgeInsets.all(22)});

  @override
  Widget build(BuildContext context) => Glass(
        radius: 24,
        child: CustomPaint(
          painter: _CornerGlow(Tok.of(context).accent.withAlpha(Tok.isDark(context) ? 50 : 34)),
          child: Padding(padding: padding, child: child),
        ),
      );
}

class _CornerGlow extends CustomPainter {
  final Color c;
  _CornerGlow(this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width, 0);
    final r = size.width * .8;
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(colors: [c, c.withAlpha(0)])
              .createShader(Rect.fromCircle(center: center, radius: r)));
  }

  @override
  bool shouldRepaint(covariant _CornerGlow old) => old.c != c;
}

/// Tarjeta oscura (tinta) para destacar una sola cosa por pantalla.
class InkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const InkCard(
      {super.key, required this.child, this.padding = const EdgeInsets.all(20), this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Tok.isDark(context);
    final br = BorderRadius.circular(24);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          BoxShadow(
              color: Brand.ink.withAlpha(dark ? 0 : 60),
              blurRadius: 30,
              offset: const Offset(0, 14),
              spreadRadius: -10),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF16203A), Brand.ink],
              ),
              borderRadius: br,
              border: Border.all(color: Colors.white.withAlpha(dark ? 30 : 0)),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: br,
              child: CustomPaint(
                painter: _CornerGlow(Brand.accent.withAlpha(110)),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pastilla con etiqueta y valor.
class GlassPill extends StatelessWidget {
  final String label, value;
  final bool onInk;
  const GlassPill({super.key, required this.label, required this.value, this.onInk = false});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final fg = onInk ? Colors.white : t.text;
    final fg2 = onInk ? Colors.white.withAlpha(150) : t.text3;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
      decoration: BoxDecoration(
        color: onInk
            ? Colors.white.withAlpha(14)
            : (Tok.isDark(context) ? t.surface2 : t.surface2.withAlpha(160)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: onInk ? Colors.white.withAlpha(24) : t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: fg2)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    fontFeatures: const [FontFeature.tabularFigures()])),
          ),
        ],
      ),
    );
  }
}

/// Entrada escalonada discreta; respeta "reducir movimiento".
class Reveal extends StatelessWidget {
  final Widget child;
  final int index;
  const Reveal({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    if (!Motion.on(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 12), child: c),
      ),
      child: child,
    );
  }
}

/// Tarjeta tocable: se hunde levemente y se tiñe al presionar (sin mover el
/// diseño), con vibración sutil al abrir.
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;
  const PressableCard({super.key, required this.child, required this.onTap, this.semanticLabel});

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final br = BorderRadius.circular(18);
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: Listener(
        onPointerDown: (_) => _set(true),
        onPointerUp: (_) => _set(false),
        onPointerCancel: (_) => _set(false),
        child: AnimatedScale(
          scale: _down ? .985 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Glass(
            radius: 18,
            shadow: !_down,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: br,
                highlightColor: t.primarySoft,
                splashColor: t.primary.withAlpha(20),
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onTap();
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Aparece (desvanece, sube y crece levemente) cuando entra en pantalla al
/// hacer scroll. Una vez visible se queda; respeta "reducir movimiento".
class ScrollReveal extends StatefulWidget {
  final Widget child;
  const ScrollReveal({super.key, required this.child});

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  ScrollPosition? _pos;
  bool _shown = false;

  /// Si aparece durante un scroll rápido se muestra sin animar, para que la
  /// lista nunca se vea vacía.
  bool _instant = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!Motion.on(context)) {
      _shown = true;
      return;
    }
    final pos = Scrollable.maybeOf(context)?.position;
    if (pos != _pos) {
      _pos?.removeListener(_check);
      _pos = pos?..addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  // Velocidad del scroll estimada entre llamadas sucesivas (px/s).
  double _lastPixels = 0;
  Duration _lastTime = Duration.zero;
  bool _fast = false;

  void _check() {
    if (_shown || !mounted) return;
    final now = SchedulerBinding.instance.currentSystemFrameTimeStamp;
    final px = _pos?.hasPixels == true ? _pos!.pixels : 0.0;
    final dt = (now - _lastTime).inMicroseconds / 1e6;
    if (dt > 0 && _lastTime != Duration.zero) _fast = (px - _lastPixels).abs() / dt > 1500;
    _lastPixels = px;
    _lastTime = now;
    final box = context.findRenderObject() as RenderBox?;
    final viewport = Scrollable.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (box == null || viewport == null || !box.hasSize || !viewport.hasSize) return;
    final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    if (top < viewport.size.height * .98) {
      setState(() {
        _shown = true;
        _instant = _fast;
      });
      _pos?.removeListener(_check);
    }
  }

  @override
  void dispose() {
    _pos?.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _instant ? Duration.zero : const Duration(milliseconds: 420);
    const c = Curves.easeOutCubic;
    return AnimatedOpacity(
      opacity: _shown ? 1 : 0,
      duration: d,
      curve: c,
      child: AnimatedSlide(
        offset: _shown ? Offset.zero : const Offset(0, .08),
        duration: d,
        curve: c,
        child: AnimatedScale(
            scale: _shown ? 1 : .97, duration: d, curve: c, child: widget.child),
      ),
    );
  }
}

/// Barra de navegación inferior de vidrio con indicador deslizante.
class GlassNavBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final List<(IconData, IconData, String)> items;
  const GlassNavBar(
      {super.key, required this.selected, required this.onChanged, required this.items});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final n = items.length;
    return _GlassBar(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(n == 1 ? 0 : -1 + 2 * selected / (n - 1), 0),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                heightFactor: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < n; i++)
                  Expanded(
                    child: Semantics(
                      selected: i == selected,
                      button: true,
                      label: items[i].$3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => onChanged(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(i == selected ? items[i].$2 : items[i].$1,
                                size: 23, color: i == selected ? t.primary : t.text3),
                            const SizedBox(height: 3),
                            Text(items[i].$3,
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight:
                                        i == selected ? FontWeight.w700 : FontWeight.w500,
                                    color: i == selected ? t.primary : t.text3)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
