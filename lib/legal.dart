import 'package:flutter/material.dart';

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
      'Calculadora Laboral es una herramienta informativa desarrollada por '
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
      'BrainCode México Tech · ${BrainCode.email} · braincode.com.mx'
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
      'BrainCode México Tech · ${BrainCode.email}'
    ),
  ];
}

class LegalPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
        children: [
          Text(headline,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.4,
                  color: t.text,
                  height: 1.2)),
          const SizedBox(height: 6),
          Text('Última actualización: 30 de octubre de 2026',
              style: TextStyle(fontSize: 13, color: t.text3)),
          const SizedBox(height: 10),
          for (final (i, s) in sections.indexed) ...[
            const SizedBox(height: 18),
            Text('${i + 1}. ${s.$1}',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: t.text)),
            const SizedBox(height: 6),
            Text(s.$2,
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 15, height: 1.6, color: t.text2)),
          ],
        ],
      ),
    );
  }
}
