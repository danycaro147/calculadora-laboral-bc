import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'braincode.dart';
import 'calc.dart';
import 'law_screens.dart';
import 'legal.dart';
import 'theme.dart';

enum TipoCalculo {
  neto('Sueldo neto', 'Lo que recibes después de ISR e IMSS', Icons.payments_outlined,
      'ISR 2026'),
  aguinaldo('Aguinaldo', 'Completo o proporcional al año', Icons.redeem_outlined, 'Art. 87'),
  vacaciones('Vacaciones', 'Días y prima vacacional', Icons.event_available_outlined,
      'Art. 76'),
  finiquito('Finiquito', 'Si renuncias o terminas tu contrato', Icons.description_outlined,
      'Art. 79'),
  liquidacion('Liquidación', 'Si te despiden sin causa justificada', Icons.gavel_outlined,
      'Art. 50');

  final String titulo, subtitulo, articulos;
  final IconData icono;
  const TipoCalculo(this.titulo, this.subtitulo, this.icono, this.articulos);
}

// ---------------------------------------------------------------------------
// Formulario
// ---------------------------------------------------------------------------

class CalcFormScreen extends StatefulWidget {
  final TipoCalculo tipo;
  const CalcFormScreen({super.key, required this.tipo});

  @override
  State<CalcFormScreen> createState() => _CalcFormScreenState();
}

class _CalcFormScreenState extends State<CalcFormScreen> {
  final _salario = TextEditingController();
  Periodicidad _per = Periodicidad.mensual;
  DateTime? _ingreso;
  DateTime _fecha = soloFecha(DateTime.now());
  late int _anio = DateTime.now().year;
  bool _yaNoTrabaja = false;
  int _diasAguinaldo = 15;
  int _prima = 25;
  int _diasPendientes = 0;
  int _vacPendientes = 0;
  int _anios = 1;
  Zona _zona = Zona.general;
  bool _veinteDias = false;
  String? _errorSalario, _errorFecha;

  TipoCalculo get t => widget.tipo;
  bool get _esSalida =>
      t == TipoCalculo.finiquito || t == TipoCalculo.liquidacion;

  @override
  void dispose() {
    _salario.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime? initial, {DateTime? first}) => showDatePicker(
        context: context,
        initialDate: initial ?? DateTime(DateTime.now().year - 1, 1, 1),
        firstDate: first ?? DateTime(1960),
        lastDate: DateTime(DateTime.now().year + 1, 12, 31),
        helpText: 'Selecciona la fecha',
      );

  void _calcular() {
    FocusScope.of(context).unfocus();
    final monto = double.tryParse(
        _salario.text.replaceAll(',', '').replaceAll(r'$', '').trim());
    setState(() {
      _errorSalario =
          (monto == null || monto <= 0) ? 'Captura tu salario bruto' : null;
      final fin = _esSalida || t == TipoCalculo.vacaciones
          ? _fecha
          : (_yaNoTrabaja ? _fecha : DateTime(_anio, 12, 31));
      _errorFecha = t == TipoCalculo.neto
          ? null
          : _ingreso == null
          ? 'Selecciona tu fecha de ingreso'
          : (_ingreso!.isAfter(fin)
              ? 'La fecha de ingreso no puede ser posterior'
              : null);
    });
    if (_errorSalario != null || _errorFecha != null) return;
    final sd = salarioDiario(monto!, _per);

    final Resultado r = switch (t) {
      TipoCalculo.neto => calcularNeto(NetoDatos(
          monto: monto,
          periodicidad: _per,
          anios: _anios,
          diasAguinaldo: _diasAguinaldo,
          primaPorcentaje: _prima.toDouble(),
          zona: _zona)),
      TipoCalculo.aguinaldo => calcularAguinaldo(AguinaldoDatos(
          salarioDiario: sd,
          ingreso: _ingreso!,
          anio: _yaNoTrabaja ? _fecha.year : _anio,
          salida: _yaNoTrabaja ? _fecha : null,
          diasAguinaldo: _diasAguinaldo)),
      TipoCalculo.vacaciones => calcularVacaciones(VacacionesDatos(
          salarioDiario: sd,
          ingreso: _ingreso!,
          fecha: _fecha,
          primaPorcentaje: _prima.toDouble())),
      _ => calcularSalida(SalidaDatos(
          salarioDiario: sd,
          ingreso: _ingreso!,
          salida: _fecha,
          diasSalarioPendiente: _diasPendientes.toDouble(),
          diasVacacionesPendientes: _vacPendientes.toDouble(),
          diasAguinaldo: _diasAguinaldo,
          primaPorcentaje: _prima.toDouble(),
          zona: _zona,
          despido: t == TipoCalculo.liquidacion,
          incluir20Dias: _veinteDias)),
    };
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultScreen(
            tipo: t,
            resultado: r,
            salarioDiario: sd,
            antiguedad: _ingreso == null || t == TipoCalculo.neto
                ? null
                : aniosDecimales(_ingreso!,
                    _esSalida || t == TipoCalculo.vacaciones ? _fecha : DateTime.now()))));
  }

  @override
  Widget build(BuildContext context) {
    final tk = Tok.of(context);
    final fechaLabel = switch (t) {
      TipoCalculo.neto => '',
      TipoCalculo.vacaciones => 'Fecha de cálculo',
      TipoCalculo.aguinaldo => 'Último día trabajado',
      TipoCalculo.liquidacion => 'Fecha del despido',
      TipoCalculo.finiquito => 'Fecha de salida',
    };

    return Scaffold(
      appBar: AppBar(title: Text(t.titulo)),
      bottomNavigationBar: BottomActionBar(children: [
        FilledButton(onPressed: _calcular, child: const Text('Calcular')),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Para(_intro()),
          const SectionTitle('Salario'),
          _Label('Salario bruto'),
          TextField(
            controller: _salario,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()]),
            decoration: InputDecoration(
              prefixText: r'$  ',
              suffixText: 'MXN',
              hintText: '0.00',
              errorText: _errorSalario,
            ),
            onChanged: (_) {
              if (_errorSalario != null) setState(() => _errorSalario = null);
            },
          ),
          const SizedBox(height: 16),
          _Label('Periodicidad de pago'),
          _Segmented<Periodicidad>(
            values: Periodicidad.values,
            selected: _per,
            label: (p) => p.etiqueta,
            onChanged: (p) => setState(() => _per = p),
          ),
          const SizedBox(height: 8),
          Text('Sin descuentos de ISR ni IMSS.',
              style: TextStyle(fontSize: 13, color: tk.text3)),
          if (t != TipoCalculo.neto) ...[
          const SectionTitle('Fechas'),
          _Label('Fecha de ingreso'),
          _DateField(
            value: _ingreso,
            error: _errorFecha,
            onTap: () async {
              final d = await _pick(_ingreso);
              if (d != null) {
                setState(() {
                  _ingreso = d;
                  _errorFecha = null;
                });
              }
            },
          ),
          if (t == TipoCalculo.aguinaldo) ...[
            const SizedBox(height: 16),
            _Label('Año del aguinaldo'),
            _Segmented<int>(
              values: [DateTime.now().year - 1, DateTime.now().year],
              selected: _anio,
              label: (y) => '$y',
              onChanged: (y) => setState(() => _anio = y),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: const Text('Ya no trabajo en esa empresa'),
                subtitle: const Text('Se calcula hasta tu último día'),
                value: _yaNoTrabaja,
                onChanged: (v) => setState(() => _yaNoTrabaja = v),
              ),
            ),
          ],
          ],
          if (t != TipoCalculo.neto && (t != TipoCalculo.aguinaldo || _yaNoTrabaja)) ...[
            const SizedBox(height: 16),
            _Label(fechaLabel),
            _DateField(
              value: _fecha,
              onTap: () async {
                final d = await _pick(_fecha, first: _ingreso);
                if (d != null) setState(() => _fecha = d);
              },
            ),
          ],
          if (_esSalida) ...[
            const SectionTitle('Adeudos'),
            GroupCard(indent: 16, children: [
              _Counter(
                  label: 'Días de sueldo sin pagar',
                  help: 'Trabajados y aún no pagados',
                  value: _diasPendientes,
                  onChanged: (v) => setState(() => _diasPendientes = v)),
              _Counter(
                  label: 'Vacaciones no disfrutadas',
                  help: 'De años anteriores',
                  value: _vacPendientes,
                  onChanged: (v) => setState(() => _vacPendientes = v)),
            ]),
          ],
          if (t == TipoCalculo.liquidacion) ...[
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: const Text('Incluir 20 días por año'),
                subtitle: const Text(
                    'Procede si el patrón se niega a reinstalarte (art. 49 y 50).'),
                value: _veinteDias,
                onChanged: (v) => setState(() => _veinteDias = v),
              ),
            ),
          ],
          const SectionTitle('Prestaciones'),
          GroupCard(indent: 16, children: [
            if (t == TipoCalculo.neto)
              _Counter(
                  label: 'Años de antigüedad',
                  help: 'Para estimar tu salario de cotización',
                  value: _anios,
                  min: 1,
                  max: 50,
                  onChanged: (v) => setState(() => _anios = v)),
            if (t != TipoCalculo.vacaciones)
              _Counter(
                  label: 'Días de aguinaldo',
                  help: 'Mínimo de ley: 15',
                  value: _diasAguinaldo,
                  min: 15,
                  onChanged: (v) => setState(() => _diasAguinaldo = v)),
            if (t != TipoCalculo.aguinaldo)
              _Counter(
                  label: 'Prima vacacional (%)',
                  help: 'Mínimo de ley: 25 %',
                  value: _prima,
                  min: 25,
                  step: 5,
                  max: 100,
                  onChanged: (v) => setState(() => _prima = v)),
          ]),
          if (_esSalida || t == TipoCalculo.neto) ...[
            const SizedBox(height: 16),
            _Label('Zona del salario mínimo'),
            _Segmented<Zona>(
              values: Zona.values,
              selected: _zona,
              label: (z) => z == Zona.general ? 'General' : 'Frontera norte',
              onChanged: (z) => setState(() => _zona = z),
            ),
          ],
          const SizedBox(height: 24),
          Text(Legal.avisoCorto,
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 12.5, color: tk.text3, height: 1.45)),
        ],
      ),
    );
  }

  String _intro() => switch (t) {
        TipoCalculo.neto =>
          'Calcula cuánto recibes realmente después de la retención de ISR, el '
              'subsidio para el empleo y las cuotas del IMSS, con las tarifas 2026.',
        TipoCalculo.aguinaldo =>
          'Por ley te corresponden al menos 15 días de salario, en proporción al '
              'tiempo trabajado durante el año.',
        TipoCalculo.vacaciones =>
          'Desde 2023 corresponden 12 días de vacaciones al cumplir el primer año, '
              'y aumentan conforme a tu antigüedad.',
        TipoCalculo.finiquito =>
          'Al terminar la relación laboral te corresponden las partes proporcionales '
              'de aguinaldo, vacaciones y prima vacacional, además de cualquier adeudo.',
        TipoCalculo.liquidacion =>
          'Ante un despido injustificado te corresponde el finiquito más una '
              'indemnización de tres meses de salario y la prima de antigüedad.',
      };
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Tok.of(context).text)),
      );
}

/// Control segmentado de ancho completo.
class _Segmented<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  const _Segmented(
      {required this.values,
      required this.selected,
      required this.label,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Container(
      height: 46,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: t.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: t.border)),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: Semantics(
                selected: v == selected,
                button: true,
                child: GestureDetector(
                  onTap: () => onChanged(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: v == selected ? t.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: v == selected ? Border.all(color: t.border) : null,
                      boxShadow: v == selected
                          ? [
                              BoxShadow(
                                  color: Colors.black.withAlpha(14),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1))
                            ]
                          : null,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(label(v),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    v == selected ? FontWeight.w700 : FontWeight.w500,
                                color: v == selected ? t.primary : t.text2)),
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

class _DateField extends StatelessWidget {
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;
  const _DateField({required this.value, required this.onTap, this.error});

  static const _m = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
    'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final err = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: t.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: err ? Theme.of(context).colorScheme.error : t.border)),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                        value == null
                            ? 'dd / mm / aaaa'
                            : '${value!.day} de ${_m[value!.month - 1]} de ${value!.year}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: value == null ? FontWeight.w400 : FontWeight.w600,
                            color: value == null ? t.text3 : t.text)),
                  ),
                  Icon(Icons.calendar_today_outlined, size: 20, color: t.text2),
                ],
              ),
            ),
          ),
        ),
        if (err)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 6),
            child: Text(error!,
                style: TextStyle(
                    fontSize: 12.5, color: Theme.of(context).colorScheme.error)),
          ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  final String label, help;
  final int value, min, max, step;
  final ValueChanged<int> onChanged;
  const _Counter(
      {required this.label,
      required this.help,
      required this.value,
      required this.onChanged,
      this.min = 0,
      this.max = 365,
      this.step = 1});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    Widget btn(IconData i, VoidCallback? f, String tip) => SizedBox(
          width: 40,
          height: 40,
          child: OutlinedButton(
            onPressed: f,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Icon(i, size: 18, semanticLabel: tip),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: t.text)),
                const SizedBox(height: 2),
                Text(help, style: TextStyle(fontSize: 13, color: t.text3)),
              ],
            ),
          ),
          btn(Icons.remove, value - step >= min ? () => onChanged(value - step) : null,
              'Menos'),
          SizedBox(
            width: 48,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                    fontFeatures: const [FontFeature.tabularFigures()])),
          ),
          btn(Icons.add, value + step <= max ? () => onChanged(value + step) : null,
              'Más'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Resultado (formato estado de cuenta)
// ---------------------------------------------------------------------------

class ResultScreen extends StatelessWidget {
  final TipoCalculo tipo;
  final Resultado resultado;
  final double salarioDiario;
  final double? antiguedad;

  const ResultScreen(
      {super.key,
      required this.tipo,
      required this.resultado,
      required this.salarioDiario,
      this.antiguedad});

  String _texto() {
    final b = StringBuffer('${resultado.titulo} — total estimado: ${dinero(resultado.total)}\n\n');
    for (final c in resultado.conceptos) {
      b.writeln(c.esDias
          ? '${c.nombre}: ${c.monto.toStringAsFixed(0)} días'
          : '${c.nombre}: ${dinero(c.monto)}'
              '${c.articulos.isNotEmpty ? ' (LFT art. ${c.articulos.join(', ')})' : ''}');
    }
    b.writeln('\nSalario diario: ${dinero(salarioDiario)}');
    b.writeln('\n${Legal.avisoCorto}');
    b.write('Finiquito MX · ${BrainCode.name}');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final r = resultado;
    final money = r.conceptos.where((c) => !c.informativo).toList();
    final info = r.conceptos.where((c) => c.informativo).toList();
    const tab = [FontFeature.tabularFigures()];

    Widget concepto(Concepto c, {bool muted = false}) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(c.nombre,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: muted ? t.text2 : t.text)),
                  ),
                  const SizedBox(width: 12),
                  Text(c.esDias ? '${c.monto.toStringAsFixed(0)} días' : dinero(c.monto),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: muted ? t.text2 : t.text,
                          fontFeatures: tab)),
                ],
              ),
              const SizedBox(height: 4),
              Text(c.detalle,
                  style: TextStyle(fontSize: 13, color: t.text3, height: 1.4)),
              if (c.articulos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 14,
                    children: [
                      for (final a in c.articulos)
                        InkWell(
                          onTap: () => openArticle(context, a),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.menu_book_outlined, size: 15, color: t.primary),
                              const SizedBox(width: 5),
                              Text('LFT art. $a',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: t.primary)),
                            ]),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      bottomNavigationBar: BottomActionBar(children: [
        OutlinedButton.icon(
          onPressed: () => Native.share(_texto()),
          icon: const Icon(Icons.ios_share_rounded, size: 20),
          label: const Text('Compartir'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Modificar datos'),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          // Resumen
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      tipo == TipoCalculo.neto
                          ? 'NETO MENSUAL ESTIMADO'
                          : '${r.titulo.toUpperCase()} · TOTAL ESTIMADO',
                      style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                          color: t.text3)),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(dinero(r.total),
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.8,
                            color: t.primary,
                            fontFeatures: tab)),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 2, width: 40, color: t.accent),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Fact('Salario diario', dinero(salarioDiario)),
                      if (antiguedad != null)
                        _Fact('Antigüedad',
                            '${antiguedad!.toStringAsFixed(antiguedad! < 10 ? 2 : 1)} años'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('Desglose'),
          Card(
            child: Column(
              children: [
                for (final (i, c) in money.indexed) ...[
                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                  concepto(c),
                ],
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: BoxDecoration(
                    color: t.surface2,
                    border: Border(top: BorderSide(color: t.text.withAlpha(60), width: 1.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(r.etiquetaTotal,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700, color: t.text))),
                      Text(dinero(r.total),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: t.text,
                              fontFeatures: tab)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (info.isNotEmpty) ...[
            const SectionTitle('Información adicional'),
            Card(
              child: Column(
                children: [
                  for (final (i, c) in info.indexed) ...[
                    if (i > 0) const Divider(indent: 16, endIndent: 16),
                    concepto(c, muted: true),
                  ],
                ],
              ),
            ),
          ],
          if (r.notas.isNotEmpty) ...[
            const SectionTitle('Notas'),
            for (final n in r.notas)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 10),
                      child: Container(
                          width: 5,
                          height: 5,
                          decoration:
                              BoxDecoration(color: t.text3, shape: BoxShape.circle)),
                    ),
                    Expanded(child: Para(n, size: 14)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 12),
          Notice(
            legal: true,
            icon: Icons.balance_outlined,
            title: 'Aviso legal',
            text: 'Este cálculo es una estimación informativa y no constituye asesoría '
                'legal. Antes de firmar un finiquito o presentar un reclamo, consulta a '
                'la PROFEDET, que brinda asesoría gratuita al ${Legal.profedetTel}.',
            action: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(spacing: 4, children: [
                TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: t.noticeText,
                        minimumSize: const Size(0, 36)),
                    onPressed: () => Native.openUrl('tel:8009117877'),
                    child: const Text('Llamar a PROFEDET')),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String label, value;
  const _Fact(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: t.text3)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: t.text,
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
