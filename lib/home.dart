import 'package:flutter/material.dart';

import 'app_state.dart';
import 'braincode.dart';
import 'calc.dart';
import 'calc_screens.dart';
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
    const titles = ['Calculadora Laboral', 'Ley Federal del Trabajo', 'Ajustes'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_tab])),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            CalcTab(onOpenLaw: () => setState(() => _tab = 1)),
            const LawTab(),
            const SettingsTab(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.calculate_outlined),
              selectedIcon: Icon(Icons.calculate_rounded),
              label: 'Calcular'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Ley'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Ajustes'),
        ],
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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final app = AppScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text('¿Qué quieres calcular?',
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Con la Ley Federal del Trabajo vigente y valores ${ValoresOficiales.anio}.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, c) {
          final w = (c.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final t in TipoCalculo.values)
                SizedBox(width: w, child: _CalcCard(tipo: t)),
            ],
          );
        }),
        const SizedBox(height: 12),
        Card(
          child: InkWell(
            onTap: onOpenLaw,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const IconTile(Icons.menu_book_rounded),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Consulta la ley completa',
                            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Busca cualquier artículo, sin internet.',
                            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
        const SectionTitle('Valores oficiales 2026'),
        const _OfficialValues(),
        if (app.showPromo) ...[
          const SizedBox(height: 24),
          BrainCodePromoCard(onDismiss: app.hidePromo),
        ],
        const SizedBox(height: 16),
        Text(Legal.avisoCorto,
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const MadeByBrainCode(),
      ],
    );
  }
}

class _CalcCard extends StatelessWidget {
  final TipoCalculo tipo;
  const _CalcCard({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CalcFormScreen(tipo: tipo))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(tipo.icono),
              const SizedBox(height: 14),
              Text(tipo.titulo,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(tipo.subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              Text(tipo.articulos,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelSmall?.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficialValues extends StatelessWidget {
  const _OfficialValues();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    Widget row(String a, String b, String c) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a, style: tt.bodyLarge),
                    Text(c, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Text(b,
                  style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        );
    return Card(
      child: Column(
        children: [
          row('Salario mínimo general', dinero(ValoresOficiales.salarioMinimoGeneral),
              'Diario, desde el 1 de enero'),
          const Divider(indent: 16),
          row('Salario mínimo frontera norte',
              dinero(ValoresOficiales.salarioMinimoFrontera), 'Diario, desde el 1 de enero'),
          const Divider(indent: 16),
          row('UMA', dinero(ValoresOficiales.umaDiaria), 'Diaria, desde el 1 de febrero'),
        ],
      ),
    );
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
    final systemDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final followSystem = app.themeMode == ThemeMode.system;
    final isDark = followSystem ? systemDark : app.themeMode == ThemeMode.dark;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Widget link(IconData i, String t, VoidCallback onTap, {String? sub}) => ListTile(
          leading: Icon(i),
          title: Text(t),
          subtitle: sub == null ? null : Text(sub),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const SectionTitle('Apariencia'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                title: const Text('Tema oscuro'),
                subtitle: Text(followSystem
                    ? 'Controlado por tu teléfono'
                    : (isDark ? 'Activado' : 'Desactivado')),
                value: isDark,
                onChanged: followSystem
                    ? null
                    : (v) => app.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
              ),
              const Divider(indent: 16),
              SwitchListTile(
                secondary: const Icon(Icons.brightness_auto_rounded),
                title: const Text('Usar el tema del teléfono'),
                value: followSystem,
                onChanged: (v) => app.setThemeMode(v
                    ? ThemeMode.system
                    : (systemDark ? ThemeMode.dark : ThemeMode.light)),
              ),
            ],
          ),
        ),
        const SectionTitle('Información legal'),
        Card(
          child: Column(
            children: [
              link(Icons.gavel_rounded, 'Términos de uso',
                  () => Navigator.of(context).push(LegalPage.terms())),
              const Divider(indent: 56),
              link(Icons.lock_outline_rounded, 'Privacidad',
                  () => Navigator.of(context).push(LegalPage.privacy())),
              const Divider(indent: 56),
              link(Icons.account_balance_rounded, 'Fuente oficial de la ley',
                  () => Native.openUrl(Legal.fuenteLey),
                  sub: 'Cámara de Diputados'),
              const Divider(indent: 56),
              link(Icons.support_agent_rounded, 'Asesoría gratuita PROFEDET',
                  () => Native.openUrl(Legal.profedetUrl),
                  sub: Legal.profedetTel),
            ],
          ),
        ),
        const SectionTitle('BrainCode México Tech'),
        Card(
          child: link(Icons.info_outline_rounded, 'Acerca de',
              () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AboutPage())),
              sub: 'Quiénes hicimos esta app'),
        ),
        const SizedBox(height: 20),
        Text(
            'Esta app no pertenece al gobierno ni está afiliada a ninguna dependencia.\n'
            '© 2026 BrainCode México Tech'
            '${app.appVersion.isNotEmpty ? ' · versión ${app.appVersion}' : ''}',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
