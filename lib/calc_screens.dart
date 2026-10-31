import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'braincode.dart';
import 'calc.dart';
import 'law_screens.dart';
import 'legal.dart';
import 'theme.dart';

enum TipoCalculo {
  aguinaldo('Aguinaldo', 'Cuánto te toca este año', Icons.card_giftcard_rounded,
      'Art. 87'),
  vacaciones('Vacaciones', 'Días y prima vacacional', Icons.beach_access_rounded,
      'Art. 76 y 80'),
  finiquito('Finiquito', 'Si renuncias', Icons.logout_rounded, 'Art. 79, 87, 162'),
  liquidacion('Liquidación', 'Si te despiden', Icons.gavel_rounded,
      'Art. 48, 50, 162');

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
        helpText: 'Elige la fecha',
      );

  void _calcular() {
    final monto =
        double.tryParse(_salario.text.replaceAll(',', '').replaceAll(r'$', '').trim());
    setState(() {
      _errorSalario = (monto == null || monto <= 0) ? 'Escribe tu salario' : null;
      final fin = _esSalida || t == TipoCalculo.vacaciones
          ? _fecha
          : (_yaNoTrabaja ? _fecha : DateTime(_anio, 12, 31));
      _errorFecha = _ingreso == null
          ? 'Elige tu fecha de ingreso'
          : (_ingreso!.isAfter(fin) ? 'La fecha de ingreso es posterior' : null);
    });
    if (_errorSalario != null || _errorFecha != null) return;
    final sd = salarioDiario(monto!, _per);

    final Resultado r = switch (t) {
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
        builder: (_) => ResultScreen(tipo: t, resultado: r, salarioDiario: sd)));
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Elegir fecha';
    const m = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final fechaLabel = switch (t) {
      TipoCalculo.vacaciones => 'Fecha de cálculo',
      TipoCalculo.aguinaldo => 'Fecha en que dejaste de trabajar',
      _ => t == TipoCalculo.liquidacion ? 'Fecha del despido' : 'Fecha de salida',
    };

    return Scaffold(
      appBar: AppBar(title: Text(t.titulo)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Text(_intro(), style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.4)),
            const SectionTitle('Tu salario'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _salario,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                      ],
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        prefixText: r'$ ',
                        hintText: '0.00',
                        labelText: 'Salario ${_per.etiqueta.toLowerCase()} bruto',
                        errorText: _errorSalario,
                      ),
                      onChanged: (_) {
                        if (_errorSalario != null) setState(() => _errorSalario = null);
                      },
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<Periodicidad>(
                      segments: [
                        for (final p in Periodicidad.values)
                          ButtonSegment(value: p, label: Text(p.etiqueta)),
                      ],
                      selected: {_per},
                      showSelectedIcon: false,
                      style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          textStyle: WidgetStatePropertyAll(TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600))),
                      onSelectionChanged: (s) => setState(() => _per = s.first),
                    ),
                    const SizedBox(height: 8),
                    Text('Sin descuentos de impuestos ni IMSS. Si te pagan por '
                        'semana o quincena, elige esa opción.',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
            const SectionTitle('Fechas'),
            Card(
              child: Column(
                children: [
                  _DateTile(
                    icon: Icons.login_rounded,
                    label: 'Fecha de ingreso',
                    value: _fmt(_ingreso),
                    error: _errorFecha,
                    onTap: () async {
                      final d = await _pick(_ingreso);
                      if (d != null) setState(() { _ingreso = d; _errorFecha = null; });
                    },
                  ),
                  if (t == TipoCalculo.aguinaldo) ...[
                    const Divider(indent: 56),
                    ListTile(
                      leading: const Icon(Icons.event_rounded),
                      title: const Text('Año del aguinaldo'),
                      trailing: DropdownButton<int>(
                        value: _anio,
                        underline: const SizedBox(),
                        items: [
                          for (final y in [DateTime.now().year, DateTime.now().year - 1])
                            DropdownMenuItem(value: y, child: Text('$y')),
                        ],
                        onChanged: (v) => setState(() => _anio = v!),
                      ),
                    ),
                    const Divider(indent: 56),
                    SwitchListTile(
                      secondary: const Icon(Icons.work_off_outlined),
                      title: const Text('Ya no trabajo ahí'),
                      subtitle: const Text('Se calcula hasta tu último día'),
                      value: _yaNoTrabaja,
                      onChanged: (v) => setState(() => _yaNoTrabaja = v),
                    ),
                  ],
                  if (t != TipoCalculo.aguinaldo || _yaNoTrabaja) ...[
                    const Divider(indent: 56),
                    _DateTile(
                      icon: Icons.logout_rounded,
                      label: fechaLabel,
                      value: _fmt(_fecha),
                      onTap: () async {
                        final d = await _pick(_fecha, first: _ingreso);
                        if (d != null) setState(() => _fecha = d);
                      },
                    ),
                  ],
                ],
              ),
            ),
            if (_esSalida) ...[
              const SectionTitle('Lo que te deben'),
              Card(
                child: Column(
                  children: [
                    _Counter(
                        label: 'Días de sueldo sin pagar',
                        help: 'Días trabajados que aún no te pagan',
                        value: _diasPendientes,
                        onChanged: (v) => setState(() => _diasPendientes = v)),
                    const Divider(indent: 16),
                    _Counter(
                        label: 'Vacaciones de años anteriores',
                        help: 'Días que no tomaste',
                        value: _vacPendientes,
                        onChanged: (v) => setState(() => _vacPendientes = v)),
                  ],
                ),
              ),
            ],
            if (t == TipoCalculo.liquidacion) ...[
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  title: const Text('Incluir 20 días por año'),
                  subtitle: const Text(
                      'Solo procede si el patrón se niega a reinstalarte '
                      '(art. 49 y 50). Muchos convenios no lo incluyen.'),
                  value: _veinteDias,
                  onChanged: (v) => setState(() => _veinteDias = v),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Card(
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: const Text('Prestaciones de tu empresa',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Si te dan más que el mínimo de ley'),
                  children: [
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
                    if (_esSalida)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Zona del salario mínimo', style: tt.bodyLarge),
                            const SizedBox(height: 8),
                            SegmentedButton<Zona>(
                              segments: const [
                                ButtonSegment(value: Zona.general, label: Text('General')),
                                ButtonSegment(value: Zona.frontera, label: Text('Frontera norte')),
                              ],
                              selected: {_zona},
                              showSelectedIcon: false,
                              onSelectionChanged: (s) => setState(() => _zona = s.first),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _calcular,
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('Calcular'),
            ),
            const SizedBox(height: 12),
            Text(Legal.avisoCorto,
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  String _intro() => switch (t) {
        TipoCalculo.aguinaldo =>
          'Por ley te corresponden al menos 15 días de salario, proporcionales al '
              'tiempo trabajado en el año.',
        TipoCalculo.vacaciones =>
          'Desde 2023 tienes 12 días de vacaciones desde el primer año, y aumentan '
              'con tu antigüedad.',
        TipoCalculo.finiquito =>
          'Al renunciar te deben pagar lo proporcional de aguinaldo, vacaciones y '
              'prima vacacional, más lo que te deban.',
        TipoCalculo.liquidacion =>
          'Si te despiden sin causa justificada te corresponde el finiquito más una '
              'indemnización y la prima de antigüedad.',
      };
}

class _DateTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final String? error;
  final VoidCallback onTap;
  const _DateTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap,
      this.error});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: error != null
          ? Text(error!, style: TextStyle(color: cs.error))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: value == 'Elegir fecha' ? cs.primary : cs.onSurface)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodyLarge),
                Text(help, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Menos',
            onPressed: value - step >= min ? () => onChanged(value - step) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 44,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()])),
          ),
          IconButton.filledTonal(
            tooltip: 'Más',
            onPressed: value + step <= max ? () => onChanged(value + step) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Resultado
// ---------------------------------------------------------------------------

class ResultScreen extends StatelessWidget {
  final TipoCalculo tipo;
  final Resultado resultado;
  final double salarioDiario;

  const ResultScreen(
      {super.key,
      required this.tipo,
      required this.resultado,
      required this.salarioDiario});

  String _texto() {
    final b = StringBuffer('${resultado.titulo} estimado: ${dinero(resultado.total)}\n');
    for (final c in resultado.conceptos) {
      if (c.esDias) {
        b.writeln('• ${c.nombre}: ${c.monto.toStringAsFixed(0)}');
      } else {
        b.writeln('• ${c.nombre}: ${dinero(c.monto)}'
            '${c.articulos.isNotEmpty ? ' (LFT art. ${c.articulos.join(', ')})' : ''}');
      }
    }
    b.writeln('\nSalario diario usado: ${dinero(salarioDiario)}');
    b.writeln('${Legal.avisoCorto}\n');
    b.write('Calculado con Calculadora Laboral de ${BrainCode.name}.');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final r = resultado;
    final esVac = tipo == TipoCalculo.vacaciones;
    final dias = esVac ? r.conceptos.firstWhere((c) => c.esDias).monto : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brand, AppColors.brandDeep],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(tipo.icono, color: Colors.white.withAlpha(220), size: 20),
                    const SizedBox(width: 8),
                    Text(r.titulo.toUpperCase(),
                        style: tt.labelMedium?.copyWith(
                            color: Colors.white.withAlpha(220),
                            letterSpacing: .8,
                            fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(dinero(r.total),
                        style: tt.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()])),
                  ),
                  const SizedBox(height: 4),
                  Text(
                      esVac
                          ? '${dias.toStringAsFixed(0)} días de vacaciones + prima vacacional'
                          : 'Total estimado antes de impuestos',
                      style: tt.bodyMedium?.copyWith(color: Colors.white.withAlpha(215))),
                ],
              ),
            ),
            const SectionTitle('Desglose'),
            Card(
              child: Column(
                children: [
                  for (final (i, c) in r.conceptos.indexed) ...[
                    if (i > 0) const Divider(indent: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(c.nombre,
                                    style: tt.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: c.informativo ? cs.onSurfaceVariant : null)),
                              ),
                              Text(
                                  c.esDias
                                      ? '${c.monto.toStringAsFixed(0)} días'
                                      : dinero(c.monto),
                                  style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: c.informativo ? cs.onSurfaceVariant : null,
                                      fontFeatures: const [FontFeature.tabularFigures()])),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.detalle,
                              style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant, height: 1.35)),
                          if (c.articulos.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final a in c.articulos)
                                  ActionChip(
                                    avatar: const Icon(Icons.menu_book_rounded, size: 16),
                                    label: Text('Art. $a'),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => openArticle(context, a),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (r.notas.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final n in r.notas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InfoBox(icon: Icons.info_outline_rounded, text: n),
                ),
            ],
            const SizedBox(height: 4),
            InfoBox(
              warning: true,
              icon: Icons.balance_rounded,
              text: 'Esto es una estimación informativa, no asesoría legal. Antes de '
                  'firmar o reclamar, la PROFEDET te asesora gratis: ${Legal.profedetTel}.',
              action: Wrap(spacing: 4, children: [
                TextButton(
                    onPressed: () => Native.openUrl('tel:8009117877'),
                    child: const Text('Llamar')),
                TextButton(
                    onPressed: () => Native.openUrl(Legal.profedetUrl),
                    child: const Text('gob.mx/profedet')),
              ]),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Native.share(_texto()),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Compartir'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Ajustar'),
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
