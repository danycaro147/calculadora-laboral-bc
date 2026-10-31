import 'package:flutter/material.dart';

import 'app_state.dart';
import 'braincode.dart';
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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Widget feature(IconData i, String t, String d) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(i),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(d,
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant, height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          children: [
            Center(
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.brand, AppColors.brandDeep],
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.brand.withAlpha(60),
                        blurRadius: 30,
                        spreadRadius: -4,
                        offset: const Offset(0, 14)),
                  ],
                ),
                child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 24),
            Text('Calcula lo que te corresponde por ley',
                textAlign: TextAlign.center,
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
            const SizedBox(height: 10),
            Text('Aguinaldo, vacaciones, finiquito y liquidación en segundos.',
                textAlign: TextAlign.center,
                style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.4)),
            const SizedBox(height: 24),
            feature(Icons.calculate_rounded, 'Cálculos claros',
                'Cada concepto te dice de dónde sale y qué artículo lo respalda.'),
            feature(Icons.menu_book_rounded, 'La ley completa, sin internet',
                'Busca en todos los artículos de la Ley Federal del Trabajo.'),
            feature(Icons.lock_rounded, 'Privada',
                'Tus datos no salen de tu teléfono.'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.balance_rounded, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('Antes de empezar',
                          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      'Los resultados son estimaciones informativas y no sustituyen la '
                      'asesoría de un abogado o de la PROFEDET. Esta app no pertenece al '
                      'gobierno; el texto de la ley proviene de la Cámara de Diputados.',
                      style: tt.bodyMedium?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      children: [
                        TextButton(
                            onPressed: () => Navigator.of(context).push(LegalPage.terms()),
                            child: const Text('Términos de uso')),
                        TextButton(
                            onPressed: () =>
                                Navigator.of(context).push(LegalPage.privacy()),
                            child: const Text('Privacidad')),
                      ],
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _ok,
                      onChanged: (v) => setState(() => _ok = v ?? false),
                      title: const Text(
                          'Entiendo que es una estimación y acepto los términos de uso.'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _ok ? () => AppScope.read(context).acceptTerms() : null,
              child: const Text('Aceptar y continuar'),
            ),
            const SizedBox(height: 8),
            const MadeByBrainCode(),
          ],
        ),
      ),
    );
  }
}
