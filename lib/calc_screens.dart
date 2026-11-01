import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'braincode.dart';
import 'calc.dart';
import 'law_screens.dart';
import 'legal.dart';
import 'theme.dart';

enum TipoCalculo {
  neto('Sueldo neto', 'Lo que recibes después de ISR e IMSS', PhosphorIconsLight.money,
      'ISR 2026'),
  aguinaldo('Aguinaldo', 'Completo o proporcional al año', PhosphorIconsLight.gift, 'Art. 87'),
  vacaciones('Vacaciones', 'Días y prima vacacional', PhosphorIconsLight.umbrellaSimple,
      'Art. 76'),
  finiquito('Finiquito', 'Si renuncias o terminas tu contrato', PhosphorIconsLight.fileText,
      'Art. 79'),
  liquidacion('Liquidación', 'Si te despiden sin causa justificada', PhosphorIconsLight.gavel,
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
    _paso = 0;
    final fechaLabel = switch (t) {
      TipoCalculo.neto => '',
      TipoCalculo.vacaciones => 'Fecha de cálculo',
      TipoCalculo.aguinaldo => 'Último día trabajado',
      TipoCalculo.liquidacion => 'Fecha del despido',
      TipoCalculo.finiquito => 'Fecha de salida',
    };

    return GlassScaffold(
      appBar: AppBar(title: Text(t.titulo)),
      bottomNavigationBar: BottomActionBar(children: [
        PrimaryButton(
          onPressed: _calcular,
          icon: PhosphorIconsLight.arrowRight,
          label: 'Calcular',
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Reveal(
            child: HeroPanel(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconTile(t.icono, size: 44),
                  const SizedBox(width: 14),
                  Expanded(child: Para(_intro(), size: 14.5, color: tk.text)),
                ],
              ),
            ),
          ),
          _step('Tu salario'),
          _Label('Salario bruto'),
          TextField(
            controller: _salario,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()]),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 6),
                child: Text(r'$',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700, color: tk.text3)),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('MXN',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800, color: tk.text3)),
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
          _step('Fechas'),
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
            Glass(
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
            _step('Adeudos'),
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
            Glass(
              child: SwitchListTile(
                title: const Text('Incluir 20 días por año'),
                subtitle: const Text(
                    'Procede si el patrón se niega a reinstalarte (art. 49 y 50).'),
                value: _veinteDias,
                onChanged: (v) => setState(() => _veinteDias = v),
              ),
            ),
          ],
          _step('Prestaciones'),
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
          const SizedBox(height: 20),
          const MadeByBrainCode(),
        ],
      ),
    );
  }

  int _paso = 0;

  /// Encabezado numerado; los números se recalculan en cada build.
  Widget _step(String text) => StepTitle(++_paso, text);

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
    final n = values.length;
    final i = values.indexOf(selected);
    return Glass(
      radius: 16,
      blur: 12,
      shadow: false,
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 46,
        child: Stack(
          children: [
            // Indicador líquido: viaja con rebote y se estira a medio camino.
            TweenAnimationBuilder<double>(
              tween: Tween(end: i.toDouble()),
              duration: const Duration(milliseconds: 480),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) {
                const mid = 0.0;
                return Align(
                  alignment: Alignment(n == 1 ? 0 : -1 + 2 * v / (n - 1), 0),
                  child: FractionallySizedBox(
                    widthFactor: (1 / n) * (1 + mid),
                    heightFactor: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.ink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              },
            ),
            Row(
              children: [
                for (final v in values)
                  Expanded(
                    child: Semantics(
                      selected: v == selected,
                      button: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(v),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 220),
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight:
                                        v == selected ? FontWeight.w800 : FontWeight.w600,
                                    color: v == selected ? t.onInk : t.text2),
                                child: Text(label(v)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
        Glass(
          radius: 18,
          blur: 12,
          shadow: false,
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Icon(PhosphorIconsLight.calendarBlank, size: 20, color: t.text3),
                  const SizedBox(width: 12),
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
                  Icon(PhosphorIconsLight.caretDown, size: 22, color: t.text3),
                ],
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
                shape: const CircleBorder()),
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
          btn(PhosphorIconsLight.minus, value - step >= min ? () => onChanged(value - step) : null,
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
          btn(PhosphorIconsLight.plus, value + step <= max ? () => onChanged(value + step) : null,
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

  /// Partes que se grafican: los conceptos positivos o, si hay descuentos
  /// (sueldo neto), lo que recibes frente a cada descuento.
  List<(String, double)> _segmentos(List<Concepto> money) {
    final dinero = money.where((c) => !c.esDias && c.monto != 0).toList();
    final negativos = dinero.where((c) => c.monto < 0).toList();
    if (negativos.isEmpty) return [for (final c in dinero) (c.nombre, c.monto)];
    return [
      ('Recibes', resultado.total),
      for (final c in negativos) (c.nombre, -c.monto),
    ];
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
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 13, color: t.text3, height: 1.4)),
              if (c.articulos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final a in c.articulos)
                        InkWell(
                          onTap: () => openArticle(context, a),
                          borderRadius: BorderRadius.circular(99),
                          child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: t.primarySoft, borderRadius: BorderRadius.circular(99)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(PhosphorIconsLight.bookOpenText, size: 14, color: t.primary),
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

    return GlassScaffold(
      appBar: AppBar(title: const Text('Resultado')),
      bottomNavigationBar: BottomActionBar(children: [
        OutlinedButton.icon(
          onPressed: () => Native.share(_texto()),
          icon: const Icon(PhosphorIconsLight.export, size: 20),
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
          Reveal(
            child: InkCard(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      tipo == TipoCalculo.neto
                          ? 'NETO MENSUAL ESTIMADO'
                          : '${r.titulo.toUpperCase()} · TOTAL ESTIMADO',
                      style: TextStyle(
                          fontSize: 11.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withAlpha(150))),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: _CountUp(
                        value: r.total,
                        style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                            color: Colors.white,
                            fontFeatures: tab)),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: GlassPill(
                              onInk: true, label: 'Salario diario', value: dinero(salarioDiario))),
                      if (antiguedad != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: GlassPill(
                              onInk: true,
                              label: 'Antigüedad',
                              value:
                                  '${antiguedad!.toStringAsFixed(antiguedad! < 10 ? 2 : 1)} años'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_segmentos(money).length > 1) ...[
            const SectionTitle('Composición'),
            _Composicion(segmentos: _segmentos(money)),
          ],
          const SectionTitle('Desglose'),
          GroupCard(
            indent: 16,
            children: [
              Column(
              children: [
                for (final (i, c) in money.indexed) ...[
                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                  concepto(c),
                ],
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: t.primarySoft,
                    border: Border(top: BorderSide(color: t.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(r.etiquetaTotal,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700, color: t.text))),
                      Text(dinero(r.total),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: t.text,
                              fontFeatures: tab)),
                    ],
                  ),
                ),
              ],
            ),
            ],
          ),
          if (info.isNotEmpty) ...[
            const SectionTitle('Información adicional'),
            GroupCard(indent: 16, children: [
              for (final c in info) concepto(c, muted: true),
            ]),
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
            icon: PhosphorIconsLight.scales,
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
          const SizedBox(height: 20),
          const MadeByBrainCode(),
        ],
      ),
    );
  }
}

/// Barra apilada con la proporción de cada concepto y su leyenda.
class _Composicion extends StatelessWidget {
  final List<(String, double)> segmentos;
  const _Composicion({required this.segmentos});


  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final colores = t.ramp;
    final total = segmentos.fold(0.0, (a, s) => a + s.$2);
    return Glass(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: Motion.on(context) ? 0 : 1, end: 1),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, v, child) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(widthFactor: v, child: child),
            ),
            child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  for (final (i, s) in segmentos.indexed)
                    Expanded(
                      flex: (s.$2 / total * 1000).round().clamp(1, 1000),
                      child: Container(
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
                        color: colores[i % colores.length],
                      ),
                    ),
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 14),
          for (final (i, s) in segmentos.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: colores[i % colores.length],
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.5, color: t.text2)),
                  ),
                  Text('${(s.$2 / total * 100).toStringAsFixed(0)} %',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                          fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Monto que cuenta desde cero al aparecer; respeta "reducir movimiento".
class _CountUp extends StatelessWidget {
  final double value;
  final TextStyle style;
  const _CountUp({required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    if (!Motion.on(context)) return Text(dinero(value), style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(dinero(v), style: style),
    );
  }
}
