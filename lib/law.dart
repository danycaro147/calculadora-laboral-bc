import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Un artículo de la Ley Federal del Trabajo.
class Articulo {
  final String id; // "87", "3o Bis", "15-A"
  final String key; // "87", "3 bis", "15-A"
  final int n;
  final String titulo;
  final String capitulo;
  final List<String> parrafos;
  final List<String> notas;
  final String norm; // texto normalizado para búsqueda

  Articulo({
    required this.id,
    required this.key,
    required this.n,
    required this.titulo,
    required this.capitulo,
    required this.parrafos,
    required this.notas,
    required this.norm,
  });

  String get nombre => 'Artículo $id';
  bool get derogado =>
      parrafos.length == 1 && normalizar(parrafos.first).contains('se deroga');
}

class Ley {
  final String version; // "14-05-2026"
  final String fuente;
  final List<Articulo> articulos;
  final Map<String, int> _porClave;

  Ley(this.version, this.fuente, this.articulos)
      : _porClave = {
          for (var i = 0; i < articulos.length; i++) articulos[i].key.toLowerCase(): i
        };

  int? indice(String key) => _porClave[key.toLowerCase()];
  Articulo? articulo(String key) {
    final i = indice(key);
    return i == null ? null : articulos[i];
  }

  /// Títulos en orden, con el índice del primer artículo.
  List<(String, int, int)> get titulos {
    final out = <(String, int, int)>[];
    for (var i = 0; i < articulos.length; i++) {
      final t = articulos[i].titulo;
      if (out.isEmpty || out.last.$1 != t) {
        out.add((t, i, 1));
      } else {
        final l = out.removeLast();
        out.add((l.$1, l.$2, l.$3 + 1));
      }
    }
    return out;
  }

  String get versionLegible {
    final p = version.split('-');
    if (p.length != 3) return version;
    const m = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
      'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final mi = int.tryParse(p[1]) ?? 1;
    return '${int.tryParse(p[0]) ?? p[0]} de ${m[(mi - 1).clamp(0, 11)]} de ${p[2]}';
  }
}

String normalizar(String s) {
  const from = 'áéíóúüñÁÉÍÓÚÜÑ';
  const to = 'aeiouunaeiouun';
  final b = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString().toLowerCase();
}

Ley _parse(String raw) {
  final j = jsonDecode(raw) as Map<String, dynamic>;
  final arts = (j['articulos'] as List).map((a) {
    final p = (a['p'] as List).cast<String>();
    final id = a['id'] as String;
    return Articulo(
      id: id,
      key: a['k'] as String,
      n: a['n'] as int,
      titulo: (a['t'] ?? '') as String,
      capitulo: (a['c'] ?? '') as String,
      parrafos: p,
      notas: ((a['notas'] ?? const []) as List).cast<String>(),
      norm: normalizar('articulo $id ${p.join(' ')}'),
    );
  }).toList();
  return Ley(j['version'] as String? ?? '', j['fuente'] as String? ?? '', arts);
}

class LeyRepo {
  static Future<Ley>? _f;

  /// La ley ya cargada (null mientras carga).
  static Ley? actual;

  static Future<Ley> cargar() => _f ??= () async {
        final raw = await rootBundle.loadString('assets/lft/lft.json');
        return actual = await compute(_parse, raw);
      }();
}

class Hallazgo {
  final int indice;
  final String fragmento;
  const Hallazgo(this.indice, this.fragmento);
}

final _artRe = RegExp(
    r'^(?:art(?:iculo)?\.?\s*)?(\d+)\s*o?\s*(-\s*[a-z]|bis|ter|quater)?\s*$');

/// Busca por número ("87", "art 162", "3 bis") o por palabras.
List<Hallazgo> buscar(Ley ley, String q, {int limite = 60}) {
  final nq = normalizar(q.trim());
  if (nq.isEmpty) return const [];
  final out = <Hallazgo>[];

  final m = _artRe.firstMatch(nq);
  if (m != null) {
    final suf = (m.group(2) ?? '').replaceAll(' ', '');
    final key = suf.isEmpty
        ? m.group(1)!
        : suf.startsWith('-')
            ? '${m.group(1)}${suf.toUpperCase()}'
            : '${m.group(1)} $suf';
    final i = ley.indice(key);
    if (i != null) out.add(Hallazgo(i, _resumen(ley.articulos[i].parrafos.first)));
    if (suf.isEmpty) {
      // También 87 Bis, 87-A, etc.
      for (var k = 0; k < ley.articulos.length; k++) {
        final a = ley.articulos[k];
        if (a.n.toString() == m.group(1) && k != i) {
          out.add(Hallazgo(k, _resumen(a.parrafos.isEmpty ? '' : a.parrafos.first)));
        }
      }
    }
    if (out.isNotEmpty) return out;
  }

  final terms = nq.split(RegExp(r'\s+')).where((t) => t.length > 1).toList();
  if (terms.isEmpty) return const [];
  final scored = <(int, int)>[];
  for (var i = 0; i < ley.articulos.length; i++) {
    final t = ley.articulos[i].norm;
    var score = 0;
    var all = true;
    for (final term in terms) {
      final c = term.allMatches(t).length;
      if (c == 0) {
        all = false;
        break;
      }
      score += c;
    }
    if (all) {
      if (t.contains(nq)) score += 50; // frase exacta
      scored.add((i, score));
    }
  }
  scored.sort((a, b) => b.$2.compareTo(a.$2));
  for (final s in scored.take(limite)) {
    out.add(Hallazgo(s.$1, _fragmento(ley.articulos[s.$1], terms.first)));
  }
  return out;
}

String _resumen(String p) => p.length > 140 ? '${p.substring(0, 140)}…' : p;

String _fragmento(Articulo a, String term) {
  final full = a.parrafos.join(' ');
  final nf = normalizar(full);
  final i = nf.indexOf(term);
  if (i < 0) return _resumen(full);
  final start = (i - 60).clamp(0, full.length);
  final end = (i + 100).clamp(0, full.length);
  return '${start > 0 ? '…' : ''}${full.substring(start, end)}${end < full.length ? '…' : ''}';
}
