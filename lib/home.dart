import 'package:flutter/material.dart';

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
    final t = Tok.of(context);
    const titles = ['Calculadora Laboral', 'Ley Federal del Trabajo', 'Ajustes'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_tab])),
      body: IndexedStack(
        index: _tab,
        children: [
          CalcTab(onOpenLaw: () => setState(() => _tab = 1)),
          const LawTab(),
          const SettingsTab(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: t.border))),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate),
                label: 'Calcular'),
            NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Ley'),
            NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Ajustes'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calcular
// ---------------------------------------------------------------------------

class CalcTab extends StatelessWidget {
  final VoidCallback onOpenLaw;
  const CalcTab({super.key, required this.onOpenLaw});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final app = AppScope.of(context);
    final ley = LeyRepo.actual;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Text('¿Qué necesitas calcular?',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -.5,
                color: t.text,
                height: 1.2)),
        const SizedBox(height: 6),
        Text('Conforme a la Ley Federal del Trabajo y a los valores oficiales '
            '${ValoresOficiales.anio}.',
            style: TextStyle(fontSize: 15, color: t.text2, height: 1.45)),
        const SectionTitle('Calculadoras'),
        GroupCard(children: [
          for (final tipo in TipoCalculo.values)
            RowTile(
              icon: tipo.icono,
              title: tipo.titulo,
              subtitle: tipo.subtitulo,
              trailingText: tipo.articulos,
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CalcFormScreen(tipo: tipo))),
            ),
        ]),
        const SectionTitle('Consulta'),
        GroupCard(children: [
          RowTile(
            icon: Icons.menu_book_outlined,
            title: 'Ley Federal del Trabajo',
            subtitle: ley == null
                ? 'Texto completo con buscador, sin internet'
                : '${ley.articulos.length} artículos · reforma DOF ${ley.version.replaceAll('-', '/')}',
            onTap: onOpenLaw,
          ),
        ]),
        const SectionTitle('Valores oficiales 2026'),
        const _OfficialValues(),
        if (app.showPromo) ...[
          const SizedBox(height: 28),
          BrainCodePromoCard(onDismiss: app.hidePromo),
        ],
        const SizedBox(height: 24),
        Text(Legal.avisoCorto,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 12.5, color: t.text3, height: 1.45)),
        const SizedBox(height: 4),
        const MadeByBrainCode(),
      ],
    );
  }
}

class _OfficialValues extends StatelessWidget {
  const _OfficialValues();

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    Widget row(String a, String c, double v) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
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
                    Text(c, style: TextStyle(fontSize: 13, color: t.text3)),
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
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              'Tema oscuro',
              followSystem ? 'Lo define tu teléfono' : (isDark ? 'Activado' : 'Desactivado'),
              isDark,
              followSystem
                  ? null
                  : (v) => app.setThemeMode(v ? ThemeMode.dark : ThemeMode.light)),
          sw(
              Icons.brightness_auto_outlined,
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
              icon: Icons.gavel_outlined,
              title: 'Términos de uso',
              onTap: () => Navigator.of(context).push(LegalPage.terms())),
          RowTile(
              icon: Icons.lock_outline,
              title: 'Aviso de privacidad',
              onTap: () => Navigator.of(context).push(LegalPage.privacy())),
          RowTile(
              icon: Icons.account_balance_outlined,
              title: 'Fuente oficial de la ley',
              subtitle: 'Cámara de Diputados',
              onTap: () => Native.openUrl(Legal.fuenteLey)),
          RowTile(
              icon: Icons.support_agent_outlined,
              title: 'Asesoría gratuita PROFEDET',
              subtitle: Legal.profedetTel,
              onTap: () => Native.openUrl(Legal.profedetUrl)),
        ]),
        const SectionTitle('Desarrollador'),
        GroupCard(children: [
          RowTile(
              icon: Icons.business_outlined,
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
      ],
    );
  }
}
