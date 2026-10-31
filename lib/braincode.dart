import 'package:flutter/material.dart';

import 'app_state.dart';
import 'legal.dart';
import 'theme.dart';

/// Datos de BrainCode México Tech (autores de la app).
class BrainCode {
  static const name = 'BrainCode México Tech';
  static const tagline = 'Tecnología que mueve a tu empresa.';
  static const email = 'contacto@braincode.com.mx';

  static String site(String campaign) =>
      'https://braincode.com.mx/?utm_source=finiquito_mx'
      '&utm_medium=app&utm_campaign=$campaign';

  static const mail = 'mailto:contacto@braincode.com.mx'
      '?subject=Contacto%20desde%20Finiquito%20MX';

  static const services = [
    (Icons.smartphone_outlined, 'Apps móviles',
        'Para tu equipo en campo y tus clientes, incluso sin conexión.'),
    (Icons.code, 'Software a la medida',
        'Portales, cotizadores y herramientas que reemplazan papel y Excel.'),
    (Icons.hub_outlined, 'Odoo ERP',
        'Implementación, nómina, facturación CFDI 4.0 y capacitación.'),
    (Icons.cloud_outlined, 'Nube AWS y Azure',
        'Migración, respaldos verificados, seguridad y control de costos.'),
  ];

  static Future<void> open(BuildContext context, String url) async {
    final ok = await Native.openUrl(url);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')));
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
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AboutPage())),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Una app de ', style: TextStyle(color: muted, fontSize: 13)),
              BrainCodeMark(size: 18, color: muted),
              const SizedBox(width: 4),
              Text(BrainCode.name,
                  style: TextStyle(
                      color: muted, fontSize: 13, fontWeight: FontWeight.w600)),
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
                        style: TextStyle(fontSize: 14, color: t.text2, height: 1.45),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Ocultar',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.close, size: 18, color: t.text3),
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

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final version = AppScope.of(context).appVersion;
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      bottomNavigationBar: BottomActionBar(children: [
        OutlinedButton(
          onPressed: () => BrainCode.open(context, BrainCode.mail),
          child: const Text('Escribir correo'),
        ),
        FilledButton(
          onPressed: () => BrainCode.open(context, BrainCode.site('acerca_de')),
          child: const Text('Visitar sitio web'),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.border)),
                child: BrainCodeMark(size: 46, color: t.text),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(BrainCode.name,
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w700, color: t.text)),
                    const SizedBox(height: 2),
                    Text(BrainCode.tagline,
                        style: TextStyle(fontSize: 14.5, color: t.text2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Para(
            'Desarrollamos Finiquito MX para que cualquier persona conozca lo '
            'que le corresponde conforme a la ley. Es gratuita, no contiene publicidad '
            'de terceros y no recopila datos personales. Si tu empresa necesita '
            'tecnología, con gusto te ayudamos.',
          ),
          const SectionTitle('Servicios'),
          GroupCard(children: [
            for (final s in BrainCode.services)
              RowTile(icon: s.$1, title: s.$2, subtitle: s.$3),
          ]),
          const SectionTitle('Contacto'),
          GroupCard(children: [
            RowTile(
                icon: Icons.public,
                title: 'braincode.com.mx',
                onTap: () => BrainCode.open(context, BrainCode.site('acerca_de'))),
            RowTile(
                icon: Icons.mail_outline,
                title: BrainCode.email,
                onTap: () => BrainCode.open(context, BrainCode.mail)),
          ]),
          const SectionTitle('Legal'),
          GroupCard(children: [
            RowTile(
                icon: Icons.gavel_outlined,
                title: 'Términos de uso',
                onTap: () => Navigator.of(context).push(LegalPage.terms())),
            RowTile(
                icon: Icons.lock_outline,
                title: 'Aviso de privacidad',
                onTap: () => Navigator.of(context).push(LegalPage.privacy())),
          ]),
          const SizedBox(height: 20),
          Text(
              '© 2026 ${BrainCode.name}. Todos los derechos reservados.'
              '${version.isNotEmpty ? '\nFiniquito MX · Versión $version' : ''}',
              style: TextStyle(fontSize: 12.5, color: t.text3, height: 1.5)),
        ],
      ),
    );
  }
}
