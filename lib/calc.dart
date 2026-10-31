// Motor de cálculo laboral (México). Funciones puras, sin interfaz.
//
// Referencias (Ley Federal del Trabajo, salvo que se indique):
//   Art. 76  Vacaciones (escala vigente desde 2023)
//   Art. 79  Vacaciones proporcionales al terminar la relación
//   Art. 80  Prima vacacional (mínimo 25 %)
//   Art. 84  Salario integrado
//   Art. 87  Aguinaldo (mínimo 15 días, proporcional)
//   Art. 48 y 50 fr. III  Indemnización de 3 meses (despido injustificado)
//   Art. 50 fr. II  20 días por año (cuando no procede la reinstalación)
//   Art. 162  Prima de antigüedad (12 días por año)
//   Art. 485 y 486  Tope de salario: doble del salario mínimo
//   LISR Art. 93 fr. XIV  Aguinaldo exento hasta 30 UMA; prima vacacional hasta 15 UMA

/// Valores oficiales que cambian cada año.
class ValoresOficiales {
  static const anio = 2026;

  /// Salario mínimo general diario 2026 (CONASAMI, DOF dic-2025).
  static const salarioMinimoGeneral = 315.04;

  /// Salario mínimo Zona Libre de la Frontera Norte 2026.
  static const salarioMinimoFrontera = 440.87;

  /// UMA diaria 2026 (INEGI, vigente desde el 1 de febrero de 2026).
  static const umaDiaria = 117.31;
}

enum Periodicidad {
  diario('Diario', 1),
  semanal('Semanal', 7),
  quincenal('Quincenal', 15),
  mensual('Mensual', 30);

  final String etiqueta;
  final int dias;
  const Periodicidad(this.etiqueta, this.dias);
}

enum Zona { general, frontera }

double salarioDiario(double monto, Periodicidad p) => monto / p.dias;

double salarioMinimo(Zona z) => z == Zona.frontera
    ? ValoresOficiales.salarioMinimoFrontera
    : ValoresOficiales.salarioMinimoGeneral;

/// Días de vacaciones para el año de servicio [anio] (1 = primer año). Art. 76.
int diasVacaciones(int anio) {
  if (anio <= 0) return 0;
  if (anio <= 5) return 12 + (anio - 1) * 2;
  return 20 + 2 * ((anio - 6) ~/ 5 + 1);
}

DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

/// Días naturales entre dos fechas, contando ambos extremos.
int diasEntre(DateTime a, DateTime b) =>
    soloFecha(b).difference(soloFecha(a)).inDays + 1;

/// Años completos cumplidos entre [ingreso] y [fecha].
int aniosCumplidos(DateTime ingreso, DateTime fecha) {
  var n = fecha.year - ingreso.year;
  final aniv = DateTime(fecha.year, ingreso.month, ingreso.day);
  if (soloFecha(fecha).isBefore(aniv)) n--;
  return n < 0 ? 0 : n;
}

/// Años de servicio con decimales (para pagos "por año").
double aniosDecimales(DateTime ingreso, DateTime fecha) {
  final n = aniosCumplidos(ingreso, fecha);
  final ultimoAniv = DateTime(ingreso.year + n, ingreso.month, ingreso.day);
  final resto = diasEntre(ultimoAniv, fecha) - 1;
  return n + (resto < 0 ? 0 : resto) / 365.0;
}

double _r(double v) => (v * 100).roundToDouble() / 100;

/// Un renglón del resultado.
class Concepto {
  final String nombre;
  final double monto;
  final String detalle;
  final List<String> articulos; // ids de artículo de la LFT, p. ej. "87"
  final bool informativo; // se muestra pero no suma al total
  final bool esDias; // el valor son días, no dinero

  const Concepto(this.nombre, this.monto, this.detalle, this.articulos,
      {this.informativo = false, this.esDias = false});
}

class Resultado {
  final String titulo;
  final List<Concepto> conceptos;
  final List<String> notas;
  final String etiquetaTotal;

  Resultado(this.titulo, this.conceptos,
      [this.notas = const [], this.etiquetaTotal = 'Total']);

  double get total =>
      _r(conceptos.where((c) => !c.informativo).fold(0.0, (a, c) => a + c.monto));
}

String _f(double v) => dinero(v);

/// Formato de dinero: $12,345.67
String dinero(double v) {
  final neg = v < 0;
  final s = v.abs().toStringAsFixed(2);
  final parts = s.split('.');
  final ent = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < ent.length; i++) {
    if (i > 0 && (ent.length - i) % 3 == 0) buf.write(',');
    buf.write(ent[i]);
  }
  return '${neg ? '-' : ''}\$$buf.${parts[1]}';
}

String _d(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

// ---------------------------------------------------------------------------
// Aguinaldo
// ---------------------------------------------------------------------------

class AguinaldoDatos {
  final double salarioDiario;
  final DateTime ingreso;
  final int anio;
  final DateTime? salida; // si ya no trabaja ahí
  final int diasAguinaldo;

  AguinaldoDatos({
    required this.salarioDiario,
    required this.ingreso,
    required this.anio,
    this.salida,
    this.diasAguinaldo = 15,
  });
}

/// Días del año [anio] trabajados entre [ingreso] y [salida] (o 31 dic).
int diasTrabajadosEnAnio(DateTime ingreso, int anio, DateTime? salida) {
  final ini = ingreso.isAfter(DateTime(anio, 1, 1)) ? ingreso : DateTime(anio, 1, 1);
  final finAnio = DateTime(anio, 12, 31);
  final fin = (salida != null && salida.isBefore(finAnio)) ? salida : finAnio;
  final d = diasEntre(ini, fin);
  return d < 0 ? 0 : d;
}

int diasDelAnio(int anio) => diasEntre(DateTime(anio, 1, 1), DateTime(anio, 12, 31));

Resultado calcularAguinaldo(AguinaldoDatos d) {
  final trabajados = diasTrabajadosEnAnio(d.ingreso, d.anio, d.salida);
  final totalAnio = diasDelAnio(d.anio);
  final prop = (trabajados / totalAnio).clamp(0.0, 1.0);
  final diasPagar = d.diasAguinaldo * prop;
  final monto = _r(d.salarioDiario * diasPagar);
  final exento = _r(
      monto < 30 * ValoresOficiales.umaDiaria ? monto : 30 * ValoresOficiales.umaDiaria);

  return Resultado('Aguinaldo ${d.anio}', [
    Concepto(
      'Aguinaldo',
      monto,
      prop >= 1
          ? '${d.diasAguinaldo} días × ${_f(d.salarioDiario)} (año completo)'
          : '${d.diasAguinaldo} días × $trabajados/$totalAnio días trabajados '
              '= ${_d(_r(diasPagar))} días × ${_f(d.salarioDiario)}',
      const ['87'],
    ),
    Concepto(
      'Parte exenta de ISR',
      exento,
      'Hasta 30 UMA (${_f(30 * ValoresOficiales.umaDiaria)}). '
          'Lo que exceda paga ISR junto con tu sueldo.',
      const [],
      informativo: true,
    ),
  ], [
    'Se paga a más tardar el 20 de diciembre.',
    if (d.diasAguinaldo > 15)
      'Usaste ${d.diasAguinaldo} días porque tu empresa da más que el mínimo de ley.',
  ]);
}

// ---------------------------------------------------------------------------
// Vacaciones
// ---------------------------------------------------------------------------

class VacacionesDatos {
  final double salarioDiario;
  final DateTime ingreso;
  final DateTime fecha;
  final double primaPorcentaje; // 25 = 25 %

  VacacionesDatos({
    required this.salarioDiario,
    required this.ingreso,
    required this.fecha,
    this.primaPorcentaje = 25,
  });
}

Resultado calcularVacaciones(VacacionesDatos d) {
  final cumplidos = aniosCumplidos(d.ingreso, d.fecha);
  // Si ya cumplió al menos un año, le corresponden las del año cumplido.
  final anioServicio = cumplidos < 1 ? 1 : cumplidos;
  final dias = diasVacaciones(anioServicio);
  final pago = _r(dias * d.salarioDiario);
  final prima = _r(pago * d.primaPorcentaje / 100);
  final exentoPrima = 15 * ValoresOficiales.umaDiaria;

  return Resultado('Vacaciones', [
    Concepto(
        'Días de vacaciones',
        dias.toDouble(),
        cumplidos < 1
            ? 'Al cumplir tu primer año tendrás $dias días.'
            : 'Por $cumplidos ${cumplidos == 1 ? 'año cumplido' : 'años cumplidos'}.',
        const ['76'],
        informativo: true,
        esDias: true),
    Concepto('Pago de vacaciones', pago,
        '$dias días × ${_f(d.salarioDiario)}', const ['76']),
    Concepto(
        'Prima vacacional',
        prima,
        '${_d(d.primaPorcentaje)} % del pago de vacaciones. Exenta de ISR '
            'hasta ${_f(exentoPrima)} (15 UMA).',
        const ['80']),
  ], [
    if (cumplidos < 1) 'Aún no cumples un año: el pago se muestra como referencia.',
    'Las vacaciones deben disfrutarse dentro de los 6 meses siguientes a cada aniversario (art. 81).',
  ]);
}

// ---------------------------------------------------------------------------
// Finiquito y liquidación
// ---------------------------------------------------------------------------

class SalidaDatos {
  final double salarioDiario;
  final DateTime ingreso;
  final DateTime salida;
  final double diasSalarioPendiente;
  final double diasVacacionesPendientes; // de años anteriores
  final int diasAguinaldo;
  final double primaPorcentaje;
  final Zona zona;
  final bool despido; // true = liquidación por despido injustificado
  final bool incluir20Dias;

  SalidaDatos({
    required this.salarioDiario,
    required this.ingreso,
    required this.salida,
    this.diasSalarioPendiente = 0,
    this.diasVacacionesPendientes = 0,
    this.diasAguinaldo = 15,
    this.primaPorcentaje = 25,
    this.zona = Zona.general,
    this.despido = false,
    this.incluir20Dias = false,
  });
}

/// Salario diario integrado aproximado (art. 84): salario + parte diaria de
/// aguinaldo y prima vacacional.
double salarioIntegrado(double sd, int diasAguinaldo, int diasVac, double primaPct) =>
    sd * (1 + (diasAguinaldo + diasVac * primaPct / 100) / 365);

Resultado calcularSalida(SalidaDatos d) {
  final sd = d.salarioDiario;
  final cumplidos = aniosCumplidos(d.ingreso, d.salida);
  final anios = aniosDecimales(d.ingreso, d.salida);
  final conceptos = <Concepto>[];
  final notas = <String>[];

  // 1. Salario pendiente
  if (d.diasSalarioPendiente > 0) {
    conceptos.add(Concepto('Salario pendiente', _r(sd * d.diasSalarioPendiente),
        '${_d(d.diasSalarioPendiente)} días × ${_f(sd)}', const ['82', '88']));
  }

  // 2. Aguinaldo proporcional
  final trab = diasTrabajadosEnAnio(d.ingreso, d.salida.year, d.salida);
  final totalAnio = diasDelAnio(d.salida.year);
  final diasAg = d.diasAguinaldo * trab / totalAnio;
  conceptos.add(Concepto('Aguinaldo proporcional', _r(sd * diasAg),
      '${d.diasAguinaldo} días × $trab/$totalAnio = ${_d(_r(diasAg))} días × ${_f(sd)}',
      const ['87']));

  // 3. Vacaciones proporcionales + pendientes
  final ultimoAniv =
      DateTime(d.ingreso.year + cumplidos, d.ingreso.month, d.ingreso.day);
  final diasPeriodo = diasEntre(ultimoAniv, d.salida) - 1;
  final vacPeriodo = diasVacaciones(cumplidos + 1) * (diasPeriodo / 365);
  final vacDias = vacPeriodo + d.diasVacacionesPendientes;
  final pagoVac = _r(sd * vacDias);
  conceptos.add(Concepto(
      'Vacaciones',
      pagoVac,
      '${_d(_r(vacPeriodo))} días proporcionales'
          '${d.diasVacacionesPendientes > 0 ? ' + ${_d(d.diasVacacionesPendientes)} pendientes' : ''}'
          ' × ${_f(sd)}',
      const ['76', '79']));
  conceptos.add(Concepto('Prima vacacional', _r(pagoVac * d.primaPorcentaje / 100),
      '${_d(d.primaPorcentaje)} % de las vacaciones', const ['80']));

  // 4. Prima de antigüedad
  final tope = 2 * salarioMinimo(d.zona);
  final sdi = salarioIntegrado(
      sd, d.diasAguinaldo, diasVacaciones(cumplidos < 1 ? 1 : cumplidos), d.primaPorcentaje);
  final basePrima = sdi > tope ? tope : sdi;
  final primaAnt = _r(12 * basePrima * anios);
  final aplicaPrima = d.despido || cumplidos >= 15;
  if (aplicaPrima) {
    conceptos.add(Concepto(
        'Prima de antigüedad',
        primaAnt,
        '12 días × ${_d(_r(anios))} años × ${_f(basePrima)}'
            '${sdi > tope ? ' (tope: 2 salarios mínimos)' : ''}',
        const ['162', '486']));
  } else {
    notas.add('Prima de antigüedad: por renuncia solo aplica con 15 años o más '
        '(art. 162). Llevas ${_d(_r(anios))} años.');
  }

  // 5. Indemnizaciones por despido injustificado
  if (d.despido) {
    conceptos.add(Concepto('Indemnización (3 meses)', _r(90 * sdi),
        '90 días × ${_f(_r(sdi))} de salario integrado', const ['48', '50']));
    if (d.incluir20Dias) {
      conceptos.add(Concepto('20 días por año', _r(20 * sdi * anios),
          '20 días × ${_d(_r(anios))} años × ${_f(_r(sdi))}', const ['50', '49']));
    }
    notas.add('Salario integrado estimado: ${_f(_r(sdi))} diarios (art. 84). Si '
        'recibes bonos, comisiones u otras prestaciones, el real puede ser mayor.');
    notas.add('No incluye salarios caídos (hasta 12 meses, art. 48), que dependen '
        'del juicio.');
  }

  notas.add('Antigüedad: ${_d(_r(anios))} años.');
  return Resultado(d.despido ? 'Liquidación' : 'Finiquito', conceptos, notas);
}


// ---------------------------------------------------------------------------
// Sueldo neto (ISR art. 96 LISR, subsidio para el empleo y cuotas IMSS)
// ---------------------------------------------------------------------------

/// Tarifa mensual ISR 2026 (Anexo 8 RMF 2026, DOF 28-12-2025):
/// (límite inferior, cuota fija, % sobre excedente)
const tarifaIsrMensual2026 = <(double, double, double)>[
  (0.01, 0.00, 1.92),
  (844.60, 16.22, 6.40),
  (7168.52, 420.95, 10.88),
  (12598.03, 1011.68, 16.00),
  (14644.65, 1339.14, 17.92),
  (17533.65, 1856.84, 21.36),
  (35362.84, 5665.16, 23.52),
  (55736.69, 10457.09, 30.00),
  (106410.51, 25659.23, 32.00),
  (141880.67, 37009.69, 34.00),
  (425642.00, 133488.54, 35.00),
];

/// Subsidio para el empleo 2026: 15.02 % de la UMA mensual, para ingresos
/// mensuales de hasta $11,492.66 (decreto de actualización para 2026).
const subsidioPorcentaje2026 = 15.02;
const subsidioTopeIngreso2026 = 11492.66;

double isrMensual(double base) {
  if (base <= 0) return 0;
  var fila = tarifaIsrMensual2026.first;
  for (final f in tarifaIsrMensual2026) {
    if (base >= f.$1) fila = f;
  }
  return fila.$2 + (base - fila.$1) * fila.$3 / 100;
}

double subsidioMensual(double base) => base <= subsidioTopeIngreso2026
    ? ValoresOficiales.umaDiaria * 30.4 * subsidioPorcentaje2026 / 100
    : 0;

/// Cuotas IMSS a cargo del trabajador, diarias, sobre el salario base de
/// cotización (SBC). Ley del Seguro Social art. 25, 106, 107, 147 y 168.
double imssObreroDiario(double sbc) {
  final uma = ValoresOficiales.umaDiaria;
  final base = sbc > 25 * uma ? 25 * uma : sbc;
  final excedente = base > 3 * uma ? (base - 3 * uma) * 0.0040 : 0.0;
  return excedente +
      base * (0.0025 + 0.00375 + 0.00625 + 0.01125); // dinero, pensionados, IV, CEAV
}

class NetoDatos {
  final double monto;
  final Periodicidad periodicidad;
  final int anios; // antigüedad para el salario integrado
  final int diasAguinaldo;
  final double primaPorcentaje;
  final Zona zona;

  NetoDatos({
    required this.monto,
    required this.periodicidad,
    this.anios = 1,
    this.diasAguinaldo = 15,
    this.primaPorcentaje = 25,
    this.zona = Zona.general,
  });
}

Resultado calcularNeto(NetoDatos d) {
  final sd = salarioDiario(d.monto, d.periodicidad);
  // Ingreso mensual: si te pagan por mes se usa tal cual; si no, salario diario × 30.4
  final mensual =
      d.periodicidad == Periodicidad.mensual ? d.monto : sd * 30.4;
  final esMinimo = sd <= salarioMinimo(d.zona) + 0.005;

  final isr = esMinimo ? 0.0 : isrMensual(mensual);
  final sub = esMinimo ? 0.0 : subsidioMensual(mensual);
  final isrRetenido = isr - sub > 0 ? isr - sub : 0.0;

  final sbc = salarioIntegrado(sd, d.diasAguinaldo,
      diasVacaciones(d.anios < 1 ? 1 : d.anios), d.primaPorcentaje);
  final imss = esMinimo ? 0.0 : imssObreroDiario(sbc) * 30.4;
  final neto = mensual - isrRetenido - imss;

  final per = d.periodicidad;
  final factor = switch (per) {
    Periodicidad.mensual => 1.0,
    Periodicidad.quincenal => 15.2 / 30.4,
    Periodicidad.semanal => 7 / 30.4,
    Periodicidad.diario => 1 / 30.4,
  };

  return Resultado('Sueldo neto mensual', [
    Concepto('Sueldo bruto', _r(mensual),
        per == Periodicidad.mensual
            ? 'Salario mensual capturado'
            : '${_f(sd)} diarios × 30.4 días', const []),
    Concepto(
        'ISR retenido',
        -_r(isrRetenido),
        esMinimo
            ? 'Salario mínimo: no se retiene ISR (art. 96 LISR).'
            : 'Tarifa art. 96 LISR 2026: ${_f(_r(isr))}'
                '${sub > 0 ? ' − subsidio para el empleo ${_f(_r(sub))}' : ''}',
        const []),
    Concepto(
        'Cuotas IMSS',
        -_r(imss),
        esMinimo
            ? 'Salario mínimo: las cubre el patrón (art. 36 LSS).'
            : 'Sobre salario base de cotización de ${_f(_r(sbc))} diarios',
        const []),
    if (per != Periodicidad.mensual)
      Concepto('Neto ${per.etiqueta.toLowerCase()}', _r(neto * factor),
          'Lo que recibirías cada pago (aproximado)', const [],
          informativo: true),
    Concepto('Neto anual', _r(neto * 12), 'Sin aguinaldo ni prima vacacional',
        const [], informativo: true),
  ], [
    'Estimación con la tarifa mensual del ISR. Tu recibo puede variar por '
        'días del periodo, faltas, horas extra, vales, Infonavit, pensión '
        'alimenticia o créditos Fonacot.',
    'No incluye aguinaldo, prima vacacional ni el ajuste anual del ISR.',
  ], 'Neto a recibir');
}
