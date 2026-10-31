import 'package:flutter/material.dart';

import 'app_state.dart';
import 'law.dart';
import 'legal.dart';
import 'theme.dart';

/// Abre un artículo por su clave ("87", "3 bis").
Future<void> openArticle(BuildContext context, String key) async {
  try {
    final ley = LeyRepo.actual ?? await LeyRepo.cargar();
    final i = ley.indice(key);
    if (!context.mounted) return;
    if (i == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró el artículo $key.')));
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ArticleScreen(ley: ley, index: i)));
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
  ('Descanso semanal', '69'),
  ('Días de descanso obligatorio', '74'),
  ('Maternidad', '170'),
  ('Terminación', '53'),
];

String _tituloCorto(String t) => t.split(' · ').first;
String _tituloNombre(String t) {
  final p = t.split(' · ');
  return p.length > 1 ? p.sublist(1).join(' ') : '';
}

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
    final t = Tok.of(context);
    return FutureBuilder<Ley>(
      future: _ley,
      initialData: LeyRepo.actual,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Notice(
                icon: Icons.error_outline,
                text: 'No se pudo cargar el texto de la ley.'),
          );
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final ley = snap.data!;
        final results = buscar(ley, _query);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            TextField(
              controller: _q,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar palabra o número de artículo',
                prefixIcon: Icon(Icons.search, color: t.text3),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Borrar',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _q.clear();
                          _query = '';
                        }),
                      ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 10),
            Text(
                '${ley.articulos.length} artículos · Última reforma publicada en el DOF '
                'el ${ley.versionLegible}',
                style: TextStyle(fontSize: 13, color: t.text3)),
            if (_query.trim().isEmpty) ...[
              const SectionTitle('Temas frecuentes'),
              GroupCard(indent: 16, children: [
                for (var i = 0; i < temasFrecuentes.length; i += 2)
                  Row(
                    children: [
                      for (final tm in temasFrecuentes.skip(i).take(2))
                        Expanded(
                          child: InkWell(
                            onTap: () => openArticle(context, tm.$2),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(tm.$1,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w600,
                                            color: t.text)),
                                  ),
                                  Text('Art. ${tm.$2}',
                                      style: TextStyle(fontSize: 12.5, color: t.text3)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ]),
              const SectionTitle('Índice'),
              GroupCard(indent: 16, children: [
                for (final tt in ley.titulos)
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => TitleScreen(
                            ley: ley, start: tt.$2, count: tt.$3, titulo: tt.$1))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_tituloCorto(tt.$1).toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        letterSpacing: .8,
                                        fontWeight: FontWeight.w700,
                                        color: t.text3)),
                                const SizedBox(height: 3),
                                Text(
                                    _tituloNombre(tt.$1).isEmpty
                                        ? _tituloCorto(tt.$1)
                                        : _tituloNombre(tt.$1),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: t.text,
                                        height: 1.3)),
                              ],
                            ),
                          ),
                          Text('${tt.$3}',
                              style: TextStyle(fontSize: 13, color: t.text3)),
                          Icon(Icons.chevron_right_rounded, color: t.text3),
                        ],
                      ),
                    ),
                  ),
              ]),
            ] else ...[
              const SizedBox(height: 16),
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text('No hay resultados para “$_query”.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: t.text2)),
                )
              else ...[
                Text('${results.length} resultado${results.length == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 13, color: t.text3)),
                const SizedBox(height: 8),
                GroupCard(indent: 16, children: [
                  for (final h in results)
                    InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              ArticleScreen(ley: ley, index: h.indice, highlight: _query))),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ley.articulos[h.indice].nombre,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: t.primary)),
                            const SizedBox(height: 4),
                            Text(h.fragmento,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: kSerif,
                                    fontSize: 14.5,
                                    color: t.text2,
                                    height: 1.45)),
                          ],
                        ),
                      ),
                    ),
                ]),
              ],
            ],
            const SizedBox(height: 24),
            const _SourceNote(),
          ],
        );
      },
    );
  }
}

class _SourceNote extends StatelessWidget {
  const _SourceNote();

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Texto obtenido de la publicación oficial de la Cámara de Diputados del H. '
          'Congreso de la Unión. Esta aplicación no pertenece al gobierno. En caso de '
          'discrepancia prevalece el texto publicado en el Diario Oficial de la Federación.',
          textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 12.5, color: t.text3, height: 1.45),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => Native.openUrl(Legal.fuenteLey),
          child: const Text('Consultar fuente oficial'),
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
    final t = Tok.of(context);
    final groups = <(String, List<int>)>[];
    for (var i = start; i < start + count; i++) {
      final c = ley.articulos[i].capitulo;
      if (groups.isEmpty || groups.last.$1 != c) groups.add((c, []));
      groups.last.$2.add(i);
    }
    return Scaffold(
      appBar: AppBar(title: Text(_tituloCorto(titulo))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Text(_tituloNombre(titulo),
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: t.text, height: 1.25)),
          const SizedBox(height: 4),
          Text('$count artículos', style: TextStyle(fontSize: 14, color: t.text3)),
          for (final g in groups) ...[
            if (g.$1.isNotEmpty) SectionTitle(g.$1.replaceAll(' · ', ' — ')),
            if (g.$1.isEmpty) const SizedBox(height: 16),
            GroupCard(indent: 16, children: [
              for (final i in g.$2)
                InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ArticleScreen(ley: ley, index: i))),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 72,
                          child: Text('Art. ${ley.articulos[i].id}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: t.primary)),
                        ),
                        Expanded(
                          child: Text(
                              ley.articulos[i].parrafos.isEmpty
                                  ? ''
                                  : ley.articulos[i].parrafos.first,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: t.text2, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ),
            ]),
          ],
        ],
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
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _i = i);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  List<TextSpan> _spans(String text, Color hl) {
    final terms = normalizar(widget.highlight)
        .split(RegExp(r'\s+'))
        .where((x) => x.length > 2 && !RegExp(r'^\d+$').hasMatch(x))
        .toList();
    if (terms.isEmpty) return [TextSpan(text: text)];
    final n = normalizar(text);
    final marks = List<bool>.filled(text.length, false);
    for (final term in terms) {
      for (final m in term.allMatches(n)) {
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
    final t = Tok.of(context);
    final body = TextStyle(
        fontFamily: kSerif, fontSize: 17 * _scale, height: 1.65, color: t.text);
    final hl = t.accent.withAlpha(70);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ley Federal del Trabajo'),
        actions: [
          IconButton(
            tooltip: 'Reducir texto',
            onPressed: _scale > .85 ? () => setState(() => _scale -= .1) : null,
            icon: const Icon(Icons.text_decrease_outlined),
          ),
          IconButton(
            tooltip: 'Aumentar texto',
            onPressed: _scale < 1.6 ? () => setState(() => _scale += .1) : null,
            icon: const Icon(Icons.text_increase_outlined),
          ),
          IconButton(
            tooltip: 'Compartir',
            onPressed: () => Native.share(
                '${a.nombre} de la Ley Federal del Trabajo\n\n'
                '${a.parrafos.join('\n\n')}\n\n'
                'Última reforma DOF ${ley.versionLegible}. Fuente: Cámara de Diputados.'),
            icon: const Icon(Icons.ios_share_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: BottomActionBar(children: [
        OutlinedButton.icon(
          onPressed: _i > 0 ? () => _go(_i - 1) : null,
          icon: const Icon(Icons.chevron_left_rounded),
          label: Text(_i > 0 ? 'Art. ${ley.articulos[_i - 1].id}' : 'Inicio'),
        ),
        OutlinedButton.icon(
          onPressed: _i < ley.articulos.length - 1 ? () => _go(_i + 1) : null,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.chevron_right_rounded),
          label: Text(_i < ley.articulos.length - 1
              ? 'Art. ${ley.articulos[_i + 1].id}'
              : 'Fin'),
        ),
      ]),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        children: [
          if (a.titulo.isNotEmpty)
            Text(a.titulo.replaceAll(' · ', ' — ').toUpperCase(),
                style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w700,
                    color: t.text3,
                    height: 1.4)),
          if (a.capitulo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(a.capitulo.replaceAll(' · ', ' — '),
                  style: TextStyle(fontSize: 14, color: t.text2, height: 1.4)),
            ),
          const SizedBox(height: 18),
          Text(a.nombre,
              style: TextStyle(
                  fontFamily: kSerif,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: t.text)),
          const SizedBox(height: 10),
          Container(height: 2, width: 40, color: t.accent),
          const SizedBox(height: 20),
          for (final p in a.parrafos)
            Padding(
              padding: EdgeInsets.only(
                  bottom: 14,
                  left: RegExp(r'^([IVXLC]+\.|[a-zñ]\))\s').hasMatch(p) ? 14 : 0),
              child: SelectableText.rich(
                TextSpan(style: body, children: _spans(p, hl)),
                textAlign: TextAlign.justify,
              ),
            ),
          if (a.notas.isNotEmpty) ...[
            const SizedBox(height: 6),
            for (final n in a.notas)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(n,
                    style: TextStyle(
                        fontFamily: kSerif,
                        fontSize: 13,
                        color: t.text3,
                        fontStyle: FontStyle.italic)),
              ),
          ],
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text('Última reforma publicada en el DOF el ${ley.versionLegible}.',
              style: TextStyle(fontSize: 12.5, color: t.text3)),
          const SizedBox(height: 6),
          const _SourceNote(),
        ],
      ),
    );
  }
}
