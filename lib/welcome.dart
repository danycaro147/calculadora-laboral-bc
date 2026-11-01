import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_state.dart';
import 'braincode.dart';
import 'calc.dart';
import 'legal.dart';
import 'theme.dart';

/// Primera pantalla: presenta la app y pide aceptar el aviso legal.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _ok = false;

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return GlassScaffold(
      bottomNavigationBar: BottomActionBar(
        top: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: _ok ? t.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _ok ? t.primary.withAlpha(90) : Colors.transparent),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _ok = !_ok),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 10, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: _ok,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (v) => setState(() => _ok = v ?? false)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                            'He leído y acepto los Términos de uso y entiendo que los '
                            'resultados son estimaciones.',
                            style: TextStyle(fontSize: 14, color: t.text, height: 1.4)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        children: [
          // Al habilitarse, el botón da un pequeño impulso para guiar la vista.
          TweenAnimationBuilder<double>(
            key: ValueKey(_ok),
            tween: Tween(begin: _ok && Motion.on(context) ? .94 : 1, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            builder: (context, v, child) => Transform.scale(scale: v, child: child),
            child: PrimaryButton(
              label: 'Aceptar y continuar',
              icon: PhosphorIconsLight.arrowRight,
              onPressed: _ok ? () => AppScope.read(context).acceptTerms() : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, top + 24, 20, 24),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const _PopIn(child: AppMark(size: 44)),
                const SizedBox(width: 12),
                Text('Finiquito MX',
                    style: TextStyle(
                        fontFamily: kSerif,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: t.text)),
              ]),
              const SizedBox(height: 32),
              Reveal(
                index: 1,
                child: Text('Calcula lo que te corresponde por ley',
                    style: TextStyle(
                        fontFamily: kSerif,
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        height: 1.12,
                        color: t.text)),
              ),
              const SizedBox(height: 12),
              const Reveal(
                index: 2,
                child: Para(
                    'Sueldo neto, aguinaldo, vacaciones, finiquito y liquidación conforme a '
                    'la Ley Federal del Trabajo, con la ley completa sin conexión.',
                    size: 15.5),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Reveal(index: 3, child: _SamplePreview()),
          const SectionTitle('Lo que incluye'),
          Reveal(
            index: 4,
            child: GroupCard(children: const [
              Reveal(
                  index: 5,
                  child: RowTile(
                      icon: PhosphorIconsLight.listChecks,
                      title: 'Cálculos fundamentados',
                      subtitle:
                          'Cada concepto muestra su fórmula y el artículo de la ley que lo respalda.')),
              Reveal(
                  index: 6,
                  child: RowTile(
                      icon: PhosphorIconsLight.bookOpenText,
                      title: 'Ley Federal del Trabajo',
                      subtitle: 'Texto vigente con buscador, índice y referencias.')),
              Reveal(
                  index: 7,
                  child: RowTile(
                      icon: PhosphorIconsLight.lock,
                      title: 'Privacidad',
                      subtitle:
                          'Tus datos se procesan en tu teléfono y no se envían a ningún servidor.')),
            ]),
          ),
          const SizedBox(height: 14),
          Reveal(
            index: 8,
            child: Notice(
              legal: true,
              icon: PhosphorIconsLight.scales,
              title: 'Antes de comenzar',
              text: 'Los resultados son estimaciones informativas y no sustituyen la '
                  'asesoría de un abogado o de la PROFEDET. Esta aplicación no pertenece '
                  'al gobierno; el texto de la ley proviene de la Cámara de Diputados.',
              action: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(spacing: 16, children: [
                  _Link(
                      'Términos de uso', () => Navigator.of(context).push(LegalPage.terms())),
                  _Link('Aviso de privacidad',
                      () => Navigator.of(context).push(LegalPage.privacy())),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const MadeByBrainCode(),
        ],
      ),
    );
  }
}

/// Vista previa de un resultado real (datos de ejemplo) que "se calcula" sola:
/// el total cuenta, la barra se llena por partes y aparecen los conceptos.
class _SamplePreview extends StatefulWidget {
  const _SamplePreview();

  @override
  State<_SamplePreview> createState() => _SamplePreviewState();
}

class _SamplePreviewState extends State<_SamplePreview> with SingleTickerProviderStateMixin {
  late final _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
  bool _started = false;

  late final _r = calcularSalida(SalidaDatos(
      salarioDiario: 600,
      ingreso: DateTime(2019, 3, 4),
      salida: DateTime(2026, 10, 15),
      despido: true));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (Motion.on(context)) {
      Future.delayed(const Duration(milliseconds: 550), () {
        if (mounted) _c.forward();
      });
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Avance de [a] a [b] dentro de la línea de tiempo, con suavizado.
  double _seg(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final r = _r;
    final partes = r.conceptos
        .where((c) => !c.informativo && !c.esDias && c.monto > 0)
        .toList()
      ..sort((a, b) => b.monto.compareTo(a.monto));
    final top = partes.take(3).toList();
    const shades = [
      Color(0xFFFFFFFF),
      Color(0xFF9FB2F4),
      Color(0xFF5677E9),
      Color(0x66FFFFFF)
    ];

    return InkCard(
      onTap: Motion.on(context) ? () => _c.forward(from: 0) : null,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final done = _c.value >= 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('LIQUIDACIÓN · EJEMPLO',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withAlpha(150))),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(done ? '7 años · \$600 diarios' : 'Calculando…',
                      key: ValueKey(done),
                      style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(150))),
                ),
              ]),
              const SizedBox(height: 10),
              Text(dinero(r.total * _seg(0, .62)),
                  style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.8,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()])),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  height: 6,
                  color: Colors.white.withAlpha(16),
                  child: Row(children: [
                    for (final (i, c) in partes.indexed)
                      Expanded(
                        flex: (c.monto / r.total * 1000).round().clamp(1, 1000),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            // Cada parte se llena después de la anterior.
                            widthFactor: _seg(.12 + i * .1, .42 + i * .1),
                            child: Container(
                              margin: EdgeInsets.only(left: i == 0 ? 0 : 2),
                              color: shades[i.clamp(0, shades.length - 1)],
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              for (final (i, c) in top.indexed)
                Opacity(
                  opacity: _seg(.5 + i * .12, .8 + i * .12),
                  child: Transform.translate(
                    offset: Offset(0, 8 * (1 - _seg(.5 + i * .12, .8 + i * .12))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration:
                                BoxDecoration(color: shades[i], shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(c.nombre,
                              style: TextStyle(
                                  fontSize: 13.5, color: Colors.white.withAlpha(200))),
                        ),
                        Text(dinero(c.monto),
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFeatures: [FontFeature.tabularFigures()])),
                      ]),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Aparición con escala suave (para la marca).
class _PopIn extends StatelessWidget {
  final Widget child;
  const _PopIn({required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Motion.on(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, v, c) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.scale(scale: .7 + .3 * v, child: c),
      ),
      child: child,
    );
  }
}

class _Link extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _Link(this.text, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(text,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Tok.of(context).primary,
                  decoration: TextDecoration.underline,
                  decorationColor: Tok.of(context).primary)),
        ),
      );
}
