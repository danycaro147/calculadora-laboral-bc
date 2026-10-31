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
    final t = Tok.of(context);

    Widget feature(IconData i, String title, String d) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(i, color: t.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, color: t.text)),
                    const SizedBox(height: 3),
                    Text(d,
                        style: TextStyle(fontSize: 14.5, color: t.text2, height: 1.45)),
                  ],
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      bottomNavigationBar: BottomActionBar(
        top: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _ok = !_ok),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
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
        children: [
          FilledButton(
            onPressed: _ok ? () => AppScope.read(context).acceptTerms() : null,
            child: const Text('Aceptar y continuar'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const Align(alignment: Alignment.centerLeft, child: AppMark(size: 56)),
            const SizedBox(height: 28),
            Text('Calcula lo que te corresponde por ley',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.6,
                    height: 1.15,
                    color: t.text)),
            const SizedBox(height: 12),
            const Para(
                'Sueldo neto, aguinaldo, vacaciones, finiquito y liquidación conforme '
                'a la Ley Federal del Trabajo, con el texto completo de la ley '
                'disponible sin conexión.',
                size: 16),
            const SizedBox(height: 28),
            feature(Icons.fact_check_outlined, 'Cálculos fundamentados',
                'Cada concepto muestra su fórmula y el artículo de la ley que lo respalda.'),
            feature(Icons.menu_book_outlined, 'Ley Federal del Trabajo',
                'Texto vigente con buscador, índice y referencias.'),
            feature(Icons.lock_outline, 'Privacidad',
                'Tus datos se procesan en tu teléfono y no se envían a ningún servidor.'),
            const SizedBox(height: 8),
            Notice(
              legal: true,
              icon: Icons.balance_outlined,
              title: 'Antes de comenzar',
              text: 'Los resultados son estimaciones informativas y no sustituyen la '
                  'asesoría de un abogado o de la PROFEDET. Esta aplicación no pertenece '
                  'al gobierno; el texto de la ley proviene de la Cámara de Diputados.',
              action: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(spacing: 16, children: [
                  _Link('Términos de uso',
                      () => Navigator.of(context).push(LegalPage.terms())),
                  _Link('Aviso de privacidad',
                      () => Navigator.of(context).push(LegalPage.privacy())),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            const MadeByBrainCode(),
          ],
        ),
      ),
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
                  color: Tok.of(context).noticeText,
                  decoration: TextDecoration.underline,
                  decorationColor: Tok.of(context).noticeText)),
        ),
      );
}
