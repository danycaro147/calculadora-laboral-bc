import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_state.dart';
import 'legal.dart';
import 'theme.dart';

/// Datos de BrainCode México Tech (autores de la app).
class BrainCode {
  static const name = 'BrainCode México Tech';
  static const tagline = 'Tecnología que mueve a tu empresa.';
  static const email = 'contacto@braincode.com.mx';

  static String site(String campaign) => 'https://braincode.com.mx/?utm_source=finiquito_mx'
      '&utm_medium=app&utm_campaign=$campaign';

  static const mail = 'mailto:contacto@braincode.com.mx'
      '?subject=Contacto%20desde%20Finiquito%20MX';

  static const services = [
    (
      PhosphorIconsLight.deviceMobile,
      'Apps móviles',
      'Para tu equipo en campo y tus clientes, incluso sin conexión.'
    ),
    (
      PhosphorIconsLight.code,
      'Software a la medida',
      'Portales, cotizadores y herramientas que reemplazan papel y Excel.'
    ),
    (
      PhosphorIconsLight.treeStructure,
      'Odoo ERP',
      'Implementación, nómina, facturación CFDI 4.0 y capacitación.'
    ),
    (
      PhosphorIconsLight.cloud,
      'Nube AWS y Azure',
      'Migración, respaldos verificados, seguridad y control de costos.'
    ),
  ];

  static Future<void> open(BuildContext context, String url) async {
    final ok = await Native.openUrl(url);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace.')));
    }
  }
}

class BrainCodeMark extends StatelessWidget {
  final double size;
  final Color? color;
  const BrainCodeMark({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/images/braincode_isotipo.png',
        width: size,
        height: size,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        colorBlendMode: BlendMode.srcIn,
        filterQuality: FilterQuality.medium,
        semanticLabel: BrainCode.name,
      );
}

class MadeByBrainCode extends StatelessWidget {
  const MadeByBrainCode({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutPage())),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Una app de ', style: TextStyle(color: muted, fontSize: 13)),
              BrainCodeMark(size: 18, color: muted),
              const SizedBox(width: 4),
              Text(BrainCode.name,
                  style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class BrainCodePromoCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const BrainCodePromoCard({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: t.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.border),
                  ),
                  child: BrainCodeMark(size: 30, color: t.text),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DE LOS CREADORES DE ESTA APP',
                          style: TextStyle(
                              fontSize: 11,
                              letterSpacing: .8,
                              fontWeight: FontWeight.w700,
                              color: t.text3)),
                      const SizedBox(height: 4),
                      Text('Soluciones de software para tu empresa',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: t.text)),
                      const SizedBox(height: 4),
                      Text(
                        'BrainCode México Tech desarrolla apps móviles, software a la '
                        'medida e implementa Odoo ERP con nómina y facturación.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 14, color: t.text2, height: 1.45),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Ocultar',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(PhosphorIconsLight.x, size: 18, color: t.text3),
                  onPressed: onDismiss,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: TextButton(
                onPressed: () => BrainCode.open(context, BrainCode.site('tarjeta_inicio')),
                child: const Text('Conocer más  →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Presentación de BrainCode: héroe espacial con el astronauta de la marca,
/// servicios, tecnologías y contacto.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const coral = Color(0xFFFA7366);
  static const tech = ['Odoo', 'Flutter', 'React', 'Python', 'AWS', 'Microsoft Azure'];

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final version = AppScope.of(context).appVersion;
    return GlassScaffold(
      bottomNavigationBar: BottomActionBar(children: [
        OutlinedButton.icon(
          onPressed: () => BrainCode.open(context, BrainCode.mail),
          icon: const Icon(PhosphorIconsLight.envelopeSimple, size: 20),
          label: const Text('Correo'),
        ),
        FilledButton.icon(
          onPressed: () => BrainCode.open(context, BrainCode.site('acerca_de')),
          icon: const Icon(PhosphorIconsLight.globeSimple, size: 20),
          label: const Text('Sitio web'),
        ),
      ]),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _SpaceHero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Reveal(
                  index: 3,
                  child: Para(
                    'Desarrollamos Finiquito MX para que cualquier persona conozca lo '
                    'que le corresponde conforme a la ley. Es gratuita, no contiene publicidad '
                    'de terceros y no recopila datos personales. Si tu empresa necesita '
                    'tecnología, con gusto te ayudamos.',
                    size: 15.5,
                  ),
                ),
                const SectionTitle('Lo que hacemos'),
                for (var r = 0; r < BrainCode.services.length; r += 2) ...[
                  if (r > 0) const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var c = r; c < r + 2 && c < BrainCode.services.length; c++) ...[
                          if (c > r) const SizedBox(width: 12),
                          Expanded(
                              child: ScrollReveal(child: _Service(BrainCode.services[c]))),
                        ],
                      ],
                    ),
                  ),
                ],
                const SectionTitle('Trabajamos con'),
                ScrollReveal(
                  child: Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final n in tech)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: t.glass,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: t.border),
                        ),
                        child: Text(n,
                            style: TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w600, color: t.text)),
                      ),
                  ]),
                ),
                const SectionTitle('Hablemos'),
                ScrollReveal(
                  child: _Contact(
                    icon: PhosphorIconsLight.globeSimple,
                    title: 'braincode.com.mx',
                    subtitle: 'Conoce nuestros proyectos y cotiza el tuyo',
                    onTap: () => BrainCode.open(context, BrainCode.site('acerca_de')),
                  ),
                ),
                const SizedBox(height: 10),
                ScrollReveal(
                  child: _Contact(
                    icon: PhosphorIconsLight.envelopeSimple,
                    title: BrainCode.email,
                    subtitle: 'Escríbenos sobre tu proyecto',
                    onTap: () => BrainCode.open(context, BrainCode.mail),
                  ),
                ),
                const SectionTitle('Legal'),
                GroupCard(children: [
                  RowTile(
                      icon: PhosphorIconsLight.gavel,
                      title: 'Términos de uso',
                      onTap: () => Navigator.of(context).push(LegalPage.terms())),
                  RowTile(
                      icon: PhosphorIconsLight.lock,
                      title: 'Aviso de privacidad',
                      onTap: () => Navigator.of(context).push(LegalPage.privacy())),
                ]),
                const SizedBox(height: 20),
                Text(
                    '© 2026 ${BrainCode.name}. Todos los derechos reservados.'
                    '${version.isNotEmpty ? '\nFiniquito MX · Versión $version' : ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: t.text3, height: 1.5)),
                const SizedBox(height: 12),
                const MadeByBrainCode(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Héroe: espacio profundo con estrellas que titilan y el astronauta flotando.
class _SpaceHero extends StatefulWidget {
  const _SpaceHero();

  @override
  State<_SpaceHero> createState() => _SpaceHeroState();
}

class _SpaceHeroState extends State<_SpaceHero> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(seconds: 7));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.on(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = .25;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    // Íconos claros en la barra de estado sobre el fondo espacial.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF070B12), Color(0xFF0E1622), Color(0xFF111C26)],
            ),
          ),
          child: CustomPaint(
            painter: _StarsPainter(_c),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, top + 6, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.white.withAlpha(20),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Regresar',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(PhosphorIconsLight.arrowLeft, color: Colors.white),
                    ),
                  ),
                  // Astronauta flotando: sube, baja y se mece suavemente.
                  SizedBox(
                    height: 270,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _c,
                        builder: (context, child) {
                          final p = _c.value * 2 * math.pi;
                          return Transform.translate(
                            offset: Offset(0, math.sin(p) * 9),
                            child:
                                Transform.rotate(angle: math.sin(p + 1) * .035, child: child),
                          );
                        },
                        child: Image.asset('assets/images/braincode_astronauta.png',
                            height: 250,
                            filterQuality: FilterQuality.medium,
                            semanticLabel: 'Astronauta de BrainCode'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Reveal(
                          child: Text('[ WE ARE BRAINCODERS ]',
                              style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 2.2,
                                  fontWeight: FontWeight.w700,
                                  color: AboutPage.coral.withAlpha(235))),
                        ),
                        const SizedBox(height: 10),
                        Reveal(
                          index: 1,
                          child: Row(children: [
                            const BrainCodeMark(size: 30, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(BrainCode.name,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -.3,
                                      color: Colors.white)),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 6),
                        Reveal(
                          index: 2,
                          child: Text(BrainCode.tagline,
                              style: TextStyle(
                                  fontFamily: kSerif,
                                  fontSize: 18,
                                  color: Colors.white.withAlpha(190))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final Animation<double> a;
  _StarsPainter(this.a) : super(repaint: a);

  static final _stars = () {
    final r = math.Random(7);
    return [
      for (var i = 0; i < 70; i++)
        (r.nextDouble(), r.nextDouble(), .5 + r.nextDouble() * 1.2, r.nextDouble() * 6.28)
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final p = a.value * 2 * math.pi;
    final paint = Paint();
    for (final (x, y, s, ph) in _stars) {
      final tw = .35 + .65 * (.5 + .5 * math.sin(p * 2 + ph));
      paint.color = Colors.white.withAlpha((tw * 200).round());
      canvas.drawCircle(Offset(x * size.width, y * size.height), s, paint);
    }
    // Brillo del planeta en la parte baja, como en el sitio.
    final c = Offset(size.width * .5, size.height * 1.55);
    canvas.drawCircle(
        c,
        size.height * .95,
        Paint()
          ..shader = RadialGradient(
            colors: [const Color(0x334C9BFF), const Color(0x00000000)],
            stops: const [.7, 1],
          ).createShader(Rect.fromCircle(center: c, radius: size.height * .95)));
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) => false;
}

class _Service extends StatelessWidget {
  final (IconData, String, String) s;
  const _Service(this.s);

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Glass(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(s.$1, size: 40),
          const SizedBox(height: 14),
          Text(s.$2,
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: t.text)),
          const SizedBox(height: 4),
          Text(s.$3, style: TextStyle(fontSize: 13, height: 1.4, color: t.text2)),
        ],
      ),
    );
  }
}

class _Contact extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _Contact(
      {required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return PressableCard(
      onTap: onTap,
      semanticLabel: title,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(children: [
          IconTile(icon, size: 42, solid: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: t.text)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 13, color: t.text2)),
              ],
            ),
          ),
          Icon(PhosphorIconsLight.arrowUpRight, size: 20, color: t.text3),
        ]),
      ),
    );
  }
}
