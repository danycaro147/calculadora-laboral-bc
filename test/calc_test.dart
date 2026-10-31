import 'package:calculadora_laboral/calc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Escala de vacaciones art. 76 (reforma 2023)', () {
    expect([for (var a = 1; a <= 12; a++) diasVacaciones(a)],
        [12, 14, 16, 18, 20, 22, 22, 22, 22, 22, 24, 24]);
    expect(diasVacaciones(16), 26);
    expect(diasVacaciones(21), 28);
    expect(diasVacaciones(26), 30);
    expect(diasVacaciones(31), 32);
  });

  test('Años cumplidos', () {
    expect(aniosCumplidos(DateTime(2020, 3, 15), DateTime(2026, 3, 14)), 5);
    expect(aniosCumplidos(DateTime(2020, 3, 15), DateTime(2026, 3, 15)), 6);
    expect(aniosCumplidos(DateTime(2026, 5, 1), DateTime(2026, 6, 1)), 0);
  });

  test('Aguinaldo año completo', () {
    final r = calcularAguinaldo(AguinaldoDatos(
        salarioDiario: 500, ingreso: DateTime(2020, 1, 1), anio: 2026));
    expect(r.total, 7500.00);
  });

  test('Aguinaldo proporcional (entró el 1 de julio)', () {
    final r = calcularAguinaldo(AguinaldoDatos(
        salarioDiario: 365, ingreso: DateTime(2026, 7, 1), anio: 2026));
    // 184 días de 365 → 15 × 184/365 = 7.5616 días × 365 = 2760
    expect(r.total, closeTo(2760, 0.01));
  });

  test('Formato de dinero', () {
    expect(dinero(1234567.891), r'$1,234,567.89');
    expect(dinero(0), r'$0.00');
    expect(dinero(999), r'$999.00');
  });

  test('Finiquito por renuncia sin prima de antigüedad', () {
    final r = calcularSalida(SalidaDatos(
        salarioDiario: 400,
        ingreso: DateTime(2023, 1, 1),
        salida: DateTime(2026, 6, 30)));
    expect(r.conceptos.any((c) => c.nombre == 'Prima de antigüedad'), isFalse);
    expect(r.total, greaterThan(0));
  });

  test('Liquidación incluye 3 meses y prima de antigüedad con tope', () {
    final r = calcularSalida(SalidaDatos(
        salarioDiario: 2000,
        ingreso: DateTime(2016, 1, 1),
        salida: DateTime(2026, 1, 1),
        despido: true));
    final ind = r.conceptos.firstWhere((c) => c.nombre.startsWith('Indemnización'));
    expect(ind.monto, greaterThan(90 * 2000));
    final prima = r.conceptos.firstWhere((c) => c.nombre == 'Prima de antigüedad');
    // 12 días × 10 años × tope (2 × 315.04)
    expect(prima.monto, closeTo(12 * 10 * 2 * 315.04, 1));
  });

  test('ISR tarifa 2026 y sueldo neto', () {
    expect(isrMensual(15000), closeTo(1339.14 + (15000 - 14644.65) * .1792, .01));
    final r = calcularNeto(NetoDatos(monto: 15000, periodicidad: Periodicidad.mensual));
    expect(r.total, closeTo(13197, 15));
    // Salario mínimo: sin ISR ni IMSS
    final m = calcularNeto(NetoDatos(monto: 315.04, periodicidad: Periodicidad.diario));
    expect(m.total, closeTo(315.04 * 30.4, .5));
    // Ingreso bajo: se resta el subsidio para el empleo (729.02 − 535.65)
    final b = calcularNeto(NetoDatos(monto: 10000, periodicidad: Periodicidad.mensual));
    expect(b.conceptos[1].monto, closeTo(-193.37, .05));
  });
}
