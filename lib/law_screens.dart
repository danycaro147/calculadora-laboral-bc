import 'package:flutter/material.dart';

import 'app_state.dart';
import 'law.dart';
import 'legal.dart';
import 'theme.dart';

/// Abre un artículo por su clave ("87", "3 bis").
Future<void> openArticle(BuildContext context, String key) async {
  try {
    final ley = await LeyRepo.cargar();
    final i = ley.indice(key);
    if (!context.mounted) return;
    if (i == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró el artículo $key.')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ArticleScreen(ley: ley, index: i)));
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La ley no está disponible.')));
    }
  }
}

const temasFrecuentes = [
  ('Aguinaldo', '87'),
  ('Vacaciones', '76'),
  ('Prima vacacional', '80'),
  ('Despido', '47'),
  ('Indemnización', '50'),
  ('Prima de antigüedad', '162'),
  ('Jornada', '61'),
  ('Horas extra', '67'),
  ('Día de descanso', '69'),
  ('Días festivos', '74'),
  ('Maternidad', '170'),
  ('Renuncia', '53'),
];

class LawTab extends StatefulWidget {
  const LawTab({super.key});

  @override
  State<LawTab> createState() => _LawTabState();
}

class _LawTabState extends State<LawTab> {
  final _q = TextEditingController();
  late final Future<Ley> _ley = LeyRepo.cargar();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return FutureBuilder<Ley>(
      future: _ley,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: InfoBox(
                warning: true,
                icon: Icons.error_outline_rounded,
                text: 'No se pudo cargar el texto de la ley.'),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final ley = snap.data!;
        final results = buscar(ley, _query);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            TextField(
              controller: _q,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Busca una palabra o número de artículo',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Borrar',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() {
                          _q.clear();
                          _query = '';
                        }),
                      ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.verified_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                      '${ley.articulos.length} artículos · última reforma DOF '
                      '${ley.versionLegible}',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ),
              ],
            ),
            if (_query.trim().isEmpty) ...[
              const SectionTitle('Temas frecuentes'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in temasFrecuentes)
                    ActionChip(
                      label: Text('${t.$1} · ${t.$2}'),
                      onPressed: () => openArticle(context, t.$2),
                    ),
                ],
              ),
              const SectionTitle('Índice'),
              Card(
                child: Column(
                  children: [
                    for (final (i, t) in ley.titulos.indexed) ...[
                      if (i > 0) const Divider(indent: 16),
                      ListTile(
                        title: Text(_tituloCorto(t.$1),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(_tituloNombre(t.$1),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Text('${t.$3}',
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => TitleScreen(
                                ley: ley, start: t.$2, count: t.$3, titulo: t.$1))),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(children: [
                    Icon(Icons.search_off_rounded, size: 44, color: cs.outline),
                    const SizedBox(height: 10),
                    Text('Sin resultados para “$_query”', style: tt.titleMedium),
                  ]),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (final (i, h) in results.indexed) ...[
                        if (i > 0) const Divider(indent: 16),
                        ListTile(
                          title: Text(ley.articulos[h.indice].nombre,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(h.fragmento,
                              maxLines: 3, overflow: TextOverflow.ellipsis),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ArticleScreen(
                                  ley: ley, index: h.indice, highlight: _query))),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 20),
            const _SourceNote(),
          ],
        );
      },
    );
  }
}

String _tituloCorto(String t) => t.split(' · ').first;
String _tituloNombre(String t) {
  final p = t.split(' · ');
  return p.length > 1 ? p.sublist(1).join(' ') : '';
}

class _SourceNote extends StatelessWidget {
  const _SourceNote();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'Texto obtenido de la publicación oficial de la Cámara de Diputados. '
          'Esta app no pertenece al gobierno.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        TextButton(
          onPressed: () => Native.openUrl(Legal.fuenteLey),
          child: const Text('Ver fuente oficial'),
        ),
      ],
    );
  }
}

class TitleScreen extends StatelessWidget {
  final Ley ley;
  final int start, count;
  final String titulo;
  const TitleScreen(
      {super.key,
      required this.ley,
      required this.start,
      required this.count,
      required this.titulo});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final items = <Widget>[];
    String? cap;
    for (var i = start; i < start + count; i++) {
      final a = ley.articulos[i];
      if (a.capitulo != cap) {
        cap = a.capitulo;
        if (cap.isNotEmpty) items.add(SectionTitle(cap));
      }
      items.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: ListTile(
            title: Text(a.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(a.parrafos.isEmpty ? '' : a.parrafos.first,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ArticleScreen(ley: ley, index: i))),
          ),
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(title: Text(_tituloCorto(titulo))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(_tituloNombre(titulo),
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            Text('$count artículos',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ...items,
          ],
        ),
      ),
    );
  }
}

class ArticleScreen extends StatefulWidget {
  final Ley ley;
  final int index;
  final String highlight;
  const ArticleScreen(
      {super.key, required this.ley, required this.index, this.highlight = ''});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late int _i = widget.index;
  double _scale = 1.0;

  List<TextSpan> _spans(String text, TextStyle base, Color hl) {
    final terms = normalizar(widget.highlight)
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2 && !RegExp(r'^\d+$').hasMatch(t))
        .toList();
    if (terms.isEmpty) return [TextSpan(text: text)];
    final n = normalizar(text);
    final marks = List<bool>.filled(text.length, false);
    for (final t in terms) {
      for (final m in t.allMatches(n)) {
        for (var k = m.start; k < m.end && k < marks.length; k++) {
          marks[k] = true;
        }
      }
    }
    final out = <TextSpan>[];
    var s = 0;
    for (var k = 1; k <= text.length; k++) {
      if (k == text.length || marks[k] != marks[s]) {
        out.add(TextSpan(
            text: text.substring(s, k),
            style: marks[s] ? TextStyle(backgroundColor: hl) : null));
        s = k;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final ley = widget.ley;
    final a = ley.articulos[_i];
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final body = tt.bodyLarge!.copyWith(height: 1.55, fontSize: 16 * _scale);

    return Scaffold(
      appBar: AppBar(
        title: Text(a.nombre),
        actions: [
          IconButton(
            tooltip: 'Texto más chico',
            onPressed: _scale > .85 ? () => setState(() => _scale -= .1) : null,
            icon: const Icon(Icons.text_decrease_rounded),
          ),
          IconButton(
            tooltip: 'Texto más grande',
            onPressed: _scale < 1.6 ? () => setState(() => _scale += .1) : null,
            icon: const Icon(Icons.text_increase_rounded),
          ),
          IconButton(
            tooltip: 'Compartir',
            onPressed: () => Native.share(
                '${a.nombre} de la Ley Federal del Trabajo\n\n'
                '${a.parrafos.join('\n\n')}\n\n'
                'Última reforma DOF ${ley.versionLegible}. Fuente: Cámara de Diputados.'),
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            if (a.titulo.isNotEmpty)
              Text(a.titulo,
                  style: tt.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w700)),
            if (a.capitulo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(a.capitulo,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ),
            const SizedBox(height: 16),
            for (final p in a.parrafos)
              Padding(
                padding: EdgeInsets.only(
                    bottom: 14,
                    left: RegExp(r'^([IVXLC]+\.|[a-z]\))\s').hasMatch(p) ? 12 : 0),
                child: SelectableText.rich(
                  TextSpan(
                      style: body,
                      children: _spans(p, body, cs.primaryContainer)),
                ),
              ),
            if (a.notas.isNotEmpty) ...[
              const SizedBox(height: 4),
              for (final n in a.notas)
                Text(n,
                    style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _i > 0 ? () => setState(() => _i--) : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: Text(_i > 0 ? 'Art. ${ley.articulos[_i - 1].id}' : '—'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _i < ley.articulos.length - 1
                        ? () => setState(() => _i++)
                        : null,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: Text(_i < ley.articulos.length - 1
                        ? 'Art. ${ley.articulos[_i + 1].id}'
                        : '—'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Ley Federal del Trabajo · última reforma DOF ${ley.versionLegible}.',
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const _SourceNote(),
          ],
        ),
      ),
    );
  }
}
