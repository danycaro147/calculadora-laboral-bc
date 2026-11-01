import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_state.dart';
import 'braincode.dart';
import 'calc.dart';
import 'calc_screens.dart';
import 'law.dart';
import 'law_screens.dart';
import 'legal.dart';
import 'theme.dart';

class HomeShell extends StatefulWidget {
  final int initialTab;
  const HomeShell({super.key, this.initialTab = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    const titles = ['Finiquito MX', 'Ley Federal del Trabajo', 'Ajustes'];
    return GlassScaffold(
      appBar: _tab == 0 ? null : AppBar(title: Text(titles[_tab])),
      body: IndexedStack(
        index: _tab,
        children: [
          CalcTab(onOpenLaw: () => setState(() => _tab = 1)),
          const LawTab(),
          const SettingsTab(),
        ],
      ),
      bottomNavigationBar: GlassNavBar(
        selected: _tab,
        onChanged: (i) => setState(() => _tab = i),
        items: const [
          (PhosphorIconsLight.calculator, PhosphorIconsFill.calculator, 'Calcular'),
          (PhosphorIconsLight.bookOpenText, PhosphorIconsFill.bookOpenText, 'Ley'),
          (PhosphorIconsLight.slidersHorizontal, PhosphorIconsFill.slidersHorizontal, 'Ajustes'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calcular
// ---------------------------------------------------------------------------

void _abrir(BuildContext context, TipoCalculo tipo) => Navigator.of(context)
    .push(MaterialPageRoute(builder: (_) => CalcFormScreen(tipo: tipo)));

class CalcTab extends StatelessWidget {
  final VoidCallback onOpenLaw;
  const CalcTab({super.key, required this.onOpenLaw});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final app = AppScope.of(context);
    final ley = LeyRepo.actual;
    final top = MediaQuery.paddingOf(context).top;
    const resto = [
      TipoCalculo.aguinaldo,
      TipoCalculo.vacaciones,
      TipoCalculo.finiquito,
      TipoCalculo.liquidacion,
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 24),
      children: [
        Row(children: [
          const AppMark(size: 40),
          const SizedBox(width: 12),
          Text('Finiquito MX',
              style: TextStyle(
                  fontFamily: kSerif, fontSize: 20, fontWeight: FontWeight.w600, color: t.text)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: t.glass,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: t.border),
            ),
            child: Text('Valores ${ValoresOficiales.anio}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.text2)),
          ),
        ]),
        const SizedBox(height: 28),
        Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Qué necesitas calcular?',
                  style: TextStyle(
                      fontFamily: kSerif,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      color: t.text)),
              const SizedBox(height: 8),
              Text('Conforme a la Ley Federal del Trabajo y a los valores oficiales vigentes.',
                  style: TextStyle(fontSize: 15, height: 1.45, color: t.text2)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Reveal(index: 1, child: _FeaturedCalc(tipo: TipoCalculo.neto)),
        const SizedBox(height: 12),
        for (var r = 0; r < resto.length; r += 2) ...[
          if (r > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Reveal(index: r + 2, child: _CalcCard(tipo: resto[r]))),
                const SizedBox(width: 12),
                Expanded(child: Reveal(index: r + 3, child: _CalcCard(tipo: resto[r + 1]))),
              ],
            ),
          ),
        ],
        const SectionTitle('Consulta'),
        GroupCard(children: [
          RowTile(
            icon: PhosphorIconsLight.bookOpenText,
            title: 'Ley Federal del Trabajo',
            subtitle: ley == null
                ? 'Texto completo con buscador, sin internet'
                : '${ley.articulos.length} artículos · reforma DOF '
                    '${ley.version.replaceAll('-', '/')}',
            onTap: onOpenLaw,
          ),
        ]),
        const SectionTitle('Valores oficiales ${ValoresOficiales.anio}'),
        const _OfficialValues(),
        if (app.showPromo) ...[
          const SizedBox(height: 28),
          BrainCodePromoCard(onDismiss: app.hidePromo),
        ],
        const SizedBox(height: 24),
        Text(Legal.avisoCorto,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 12.5, color: t.text3, height: 1.5)),
        const SizedBox(height: 4),
        const MadeByBrainCode(),
      ],
    );
  }
}

/// Calculadora principal destacada en tarjeta de tinta.
class _FeaturedCalc extends StatelessWidget {
  final TipoCalculo tipo;
  const _FeaturedCalc({required this.tipo});

  @override
  Widget build(BuildContext context) => InkCard(
        onTap: () => _abrir(context, tipo),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: Icon(tipo.icono, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Text(tipo.articulos,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withAlpha(150))),
            ]),
            const SizedBox(height: 22),
            Text(tipo.titulo,
                style: const TextStyle(
                    fontFamily: kSerif,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: Text(tipo.subtitulo,
                    style: TextStyle(fontSize: 14, height: 1.4, color: Colors.white.withAlpha(180))),
              ),
              const SizedBox(width: 12),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(PhosphorIconsLight.arrowRight, size: 19, color: Brand.ink),
              ),
            ]),
          ],
        ),
      );
}

/// Tarjeta de vidrio de una calculadora.
class _CalcCard extends StatelessWidget {
  final TipoCalculo tipo;
  const _CalcCard({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Glass(
      onTap: () => _abrir(context, tipo),
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(tipo.icono, size: 40),
              const Spacer(),
              Text(tipo.articulos,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.text3)),
            ],
          ),
          const SizedBox(height: 16),
          Text(tipo.titulo,
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: t.text)),
          const SizedBox(height: 4),
          Text(tipo.subtitulo, style: TextStyle(fontSize: 13, height: 1.35, color: t.text2)),
        ],
      ),
    );
  }
}

class _OfficialValues extends StatelessWidget {
  const _OfficialValues();

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    Widget row(String a, String sub, double v) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600, color: t.text)),
                    const SizedBox(height: 2),
                    Text(sub, style: TextStyle(fontSize: 12.5, color: t.text3)),
                  ],
                ),
              ),
              Text(dinero(v),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: t.text,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        );
    return GroupCard(indent: 16, children: [
      row('Salario mínimo general', 'Diario · vigente desde el 1 de enero',
          ValoresOficiales.salarioMinimoGeneral),
      row('Salario mínimo frontera norte', 'Diario · vigente desde el 1 de enero',
          ValoresOficiales.salarioMinimoFrontera),
      row('UMA', 'Diaria · vigente desde el 1 de febrero', ValoresOficiales.umaDiaria),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Ajustes
// ---------------------------------------------------------------------------

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = Tok.of(context);
    final systemDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final followSystem = app.themeMode == ThemeMode.system;
    final isDark = followSystem ? systemDark : app.themeMode == ThemeMode.dark;

    Widget sw(IconData i, String title, String sub, bool v, ValueChanged<bool>? f) =>
        RowTile(
          icon: i,
          title: title,
          subtitle: sub,
          trailing: Switch(value: v, onChanged: f),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        const SectionTitle('Apariencia', padding: EdgeInsets.fromLTRB(4, 12, 4, 10)),
        GroupCard(children: [
          sw(
              isDark ? PhosphorIconsLight.moon : PhosphorIconsLight.sun,
              'Tema oscuro',
              followSystem ? 'Lo define tu teléfono' : (isDark ? 'Activado' : 'Desactivado'),
              isDark,
              followSystem
                  ? null
                  : (v) => app.setThemeMode(v ? ThemeMode.dark : ThemeMode.light)),
          sw(
              PhosphorIconsLight.circleHalf,
              'Usar el tema del teléfono',
              'Cambia automáticamente entre claro y oscuro',
              followSystem,
              (v) => app.setThemeMode(v
                  ? ThemeMode.system
                  : (systemDark ? ThemeMode.dark : ThemeMode.light))),
        ]),
        const SectionTitle('Información legal'),
        GroupCard(children: [
          RowTile(
              icon: PhosphorIconsLight.gavel,
              title: 'Términos de uso',
              onTap: () => Navigator.of(context).push(LegalPage.terms())),
          RowTile(
              icon: PhosphorIconsLight.lock,
              title: 'Aviso de privacidad',
              onTap: () => Navigator.of(context).push(LegalPage.privacy())),
          RowTile(
              icon: PhosphorIconsLight.bank,
              title: 'Fuente oficial de la ley',
              subtitle: 'Cámara de Diputados',
              onTap: () => Native.openUrl(Legal.fuenteLey)),
          RowTile(
              icon: PhosphorIconsLight.headset,
              title: 'Asesoría gratuita PROFEDET',
              subtitle: Legal.profedetTel,
              onTap: () => Native.openUrl(Legal.profedetUrl)),
        ]),
        const SectionTitle('Desarrollador'),
        GroupCard(children: [
          RowTile(
              icon: PhosphorIconsLight.buildings,
              title: BrainCode.name,
              subtitle: 'Acerca de quienes desarrollamos esta app',
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AboutPage()))),
        ]),
        const SizedBox(height: 24),
        Text(
            'Esta app no pertenece al gobierno ni está afiliada a ninguna dependencia.',
            style: TextStyle(fontSize: 12.5, color: t.text3, height: 1.45)),
        const SizedBox(height: 4),
        Text(
            '© 2026 ${BrainCode.name}'
            '${app.appVersion.isNotEmpty ? ' · Versión ${app.appVersion}' : ''}',
            style: TextStyle(fontSize: 12.5, color: t.text3)),
        const SizedBox(height: 20),
        const MadeByBrainCode(),
      ],
    );
  }
}
