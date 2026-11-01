import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'braincode.dart';
import 'theme.dart';

/// Textos legales. Se publican también en TERMINOS.md y PRIVACIDAD.md.
class Legal {
  static const fuenteLey = 'https://www.diputados.gob.mx/LeyesBiblio/ref/lft.htm';
  static const profedetTel = '800 911 7877';
  static const profedetUrl = 'https://www.gob.mx/profedet';

  static const avisoCorto =
      'Los resultados son una estimación informativa y no constituyen asesoría '
      'legal. Esta app no pertenece al gobierno.';

  static const terminos = [
    (
      'Naturaleza de la app',
      'Finiquito MX es una herramienta informativa desarrollada por '
          'BrainCode México Tech. Sus resultados son estimaciones basadas en los '
          'datos que tú capturas y en reglas generales de la Ley Federal del Trabajo. '
          'No constituyen asesoría legal, contable ni fiscal, ni crean una relación '
          'abogado-cliente.'
    ),
    (
      'No es una app del gobierno',
      'Esta app no está afiliada, patrocinada ni avalada por ninguna dependencia de '
          'gobierno. El texto de la Ley Federal del Trabajo se obtuvo de la '
          'publicación de la Cámara de Diputados (diputados.gob.mx), que es la '
          'fuente de referencia. Ante cualquier diferencia, prevalece el texto '
          'publicado en el Diario Oficial de la Federación.'
    ),
    (
      'Exactitud y vigencia',
      'Hacemos un esfuerzo razonable por mantener la ley, el salario mínimo y la UMA '
          'actualizados, pero las leyes cambian y cada caso tiene particularidades '
          '(contratos colectivos, prestaciones superiores a la ley, salario '
          'integrado, resoluciones de autoridad, etc.). La app se ofrece "tal cual", '
          'sin garantía de exactitud, integridad o idoneidad para un fin específico.'
    ),
    (
      'Limitación de responsabilidad',
      'En la máxima medida permitida por la ley, BrainCode México Tech no será '
          'responsable por daños o perjuicios derivados del uso o la imposibilidad de '
          'uso de la app, ni por decisiones tomadas con base en sus resultados. Antes '
          'de firmar un finiquito o iniciar un reclamo, consulta a la PROFEDET '
          '(asesoría gratuita, $profedetTel) o a un abogado laboral.'
    ),
    (
      'Propiedad intelectual',
      'El código, diseño, íconos, textos propios, marca y logotipo de la app son '
          'propiedad de BrainCode México Tech. Queda prohibida su copia, '
          'modificación o distribución sin autorización por escrito. El texto de la '
          'ley es de dominio público.'
    ),
    (
      'Ley aplicable',
      'Estos términos se rigen por las leyes de los Estados Unidos Mexicanos. '
          'Cualquier controversia se someterá a los tribunales competentes de la '
          'Ciudad de México.'
    ),
    (
      'Contacto',
      'BrainCode México Tech\n${BrainCode.email}\nbraincode.com.mx'
    ),
  ];

  static const privacidad = [
    (
      'Tus datos no salen de tu teléfono',
      'Los salarios, fechas y resultados que capturas se procesan solo en tu '
          'dispositivo y no se guardan ni se envían a nadie. La app no tiene permiso '
          'de acceso a internet, no usa cuentas, analíticas ni anuncios de terceros.'
    ),
    (
      'Qué se guarda',
      'Solo tus preferencias (tema claro u oscuro) y la aceptación de los términos, '
          'en el almacenamiento privado de la app. Se eliminan al desinstalarla.'
    ),
    (
      'Compartir',
      'Si usas "Compartir", tú eliges la app y el destinatario; la información se '
          'envía desde tu teléfono.'
    ),
    (
      'Contacto',
      'BrainCode México Tech\n${BrainCode.email}'
    ),
  ];
}

class LegalPage extends StatefulWidget {
  final String title;
  final String headline;
  final List<(String, String)> sections;

  const LegalPage(
      {super.key,
      required this.title,
      required this.headline,
      required this.sections});

  static Route terms() => MaterialPageRoute(
      builder: (_) => const LegalPage(
          title: 'Términos de uso',
          headline: 'Aviso legal y términos de uso',
          sections: Legal.terminos));

  static Route privacy() => MaterialPageRoute(
      builder: (_) => const LegalPage(
          title: 'Aviso de privacidad',
          headline: 'Tus datos no salen de tu teléfono',
          sections: Legal.privacidad));

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  final _scroll = ScrollController();
  late final _keys = [for (final _ in widget.sections) GlobalKey()];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    final ctx = _keys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: Motion.on(context) ? const Duration(milliseconds: 650) : Duration.zero,
        curve: Curves.easeInOutCubic,
        alignment: .04);
  }

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final palabras = widget.sections
        .fold(0, (n, s) => n + '${s.$1} ${s.$2}'.split(RegExp(r'\s+')).length);
    final minutos = (palabras / 200).ceil();

    return GlassScaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // Progreso de lectura.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: AnimatedBuilder(
            animation: _scroll,
            builder: (context, _) {
              final p = _scroll.hasClients && _scroll.position.hasContentDimensions &&
                      _scroll.position.maxScrollExtent > 0
                  ? (_scroll.offset / _scroll.position.maxScrollExtent).clamp(0.0, 1.0)
                  : 0.0;
              return Container(
                height: 3,
                color: t.border,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: p,
                  child: Container(color: t.primary),
                ),
              );
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Reveal(
                  child: Text(widget.headline,
                      style: TextStyle(
                          fontFamily: kSerif,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: t.text,
                          height: 1.2)),
                ),
                const SizedBox(height: 8),
                Reveal(
                  index: 1,
                  child: Row(children: [
                    Icon(PhosphorIconsLight.calendarBlank, size: 15, color: t.text3),
                    const SizedBox(width: 6),
                    Text('30 de octubre de 2026', style: TextStyle(fontSize: 13, color: t.text3)),
                    const SizedBox(width: 14),
                    Icon(PhosphorIconsLight.clock, size: 15, color: t.text3),
                    const SizedBox(width: 6),
                    Text('Lectura de $minutos min',
                        style: TextStyle(fontSize: 13, color: t.text3)),
                  ]),
                ),
                const SizedBox(height: 18),
                // Índice: lleva a cada sección.
                Reveal(
                  index: 2,
                  child: Glass(
                    padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                          child: Text('CONTENIDO',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.3,
                                  color: t.text3)),
                        ),
                        for (final (i, s) in widget.sections.indexed)
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _goTo(i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(children: [
                                SizedBox(
                                  width: 26,
                                  child: Text('${i + 1}'.padLeft(2, '0'),
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: t.primary,
                                          fontFeatures: const [FontFeature.tabularFigures()])),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(s.$1,
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: t.text)),
                                ),
                                Icon(PhosphorIconsLight.arrowDown, size: 16, color: t.text3),
                              ]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                for (final (i, s) in widget.sections.indexed)
                  Padding(
                    key: _keys[i],
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ScrollReveal(
                      child: Glass(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: t.primary, width: 1.5)),
                                child: Text('${i + 1}',
                                    style: TextStyle(
                                        color: t.primary,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(s.$1,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: t.text)),
                              ),
                            ]),
                            const SizedBox(height: 10),
                            Text(s.$2,
                                textAlign: TextAlign.justify,
                                style: TextStyle(fontSize: 15, height: 1.6, color: t.text2)),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const MadeByBrainCode(),
              ],
            ),
          ),
          // Volver arriba: aparece al bajar.
          Positioned(
            right: 20,
            bottom: 20,
            child: AnimatedBuilder(
              animation: _scroll,
              builder: (context, child) {
                final show = _scroll.hasClients && _scroll.offset > 600;
                return IgnorePointer(
                  ignoring: !show,
                  child: AnimatedScale(
                    scale: show ? 1 : .6,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: show ? 1 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: child,
                    ),
                  ),
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: softShadow(context)),
                child: Material(
                  color: t.ink,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _scroll.animateTo(0,
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeInOutCubic),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Icon(PhosphorIconsLight.arrowUp,
                          size: 22, color: t.onInk, semanticLabel: 'Volver arriba'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
