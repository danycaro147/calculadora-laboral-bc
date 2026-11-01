import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_state.dart';
import 'braincode.dart';
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

String _romano(int n) {
  const v = [(10, 'X'), (9, 'IX'), (5, 'V'), (4, 'IV'), (1, 'I')];
  final b = StringBuffer();
  for (final (k, r) in v) {
    while (n >= k) {
      b.write(r);
      n -= k;
    }
  }
  return b.toString();
}

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
                icon: PhosphorIconsLight.warningCircle,
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
                prefixIcon: Icon(PhosphorIconsLight.magnifyingGlass, color: t.text3),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Borrar',
                        icon: const Icon(PhosphorIconsLight.x),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tm in temasFrecuentes)
                    Glass(
                      radius: 99,
                      blur: 10,
                      shadow: false,
                      onTap: () => openArticle(context, tm.$2),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: null,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 9, 8, 9),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(tm.$1,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: t.text)),
                            const SizedBox(width: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                  color: t.primarySoft,
                                  borderRadius: BorderRadius.circular(99)),
                              child: Text(tm.$2,
                                  style: TextStyle(
                                      color: t.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                        ),
                      ),
                    ),
                ],
              ),
              const SectionTitle('Índice'),
              GroupCard(indent: 66, children: [
                for (final (n, tt) in ley.titulos.indexed)
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => TitleScreen(
                            ley: ley, start: tt.$2, count: tt.$3, titulo: tt.$1))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: t.primarySoft,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(_romano(n + 1),
                                style: TextStyle(
                                    fontFamily: kSerif,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: t.primary)),
                          ),
                          const SizedBox(width: 14),
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
                          Icon(PhosphorIconsLight.caretRight, color: t.text3),
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
                                textAlign: TextAlign.justify,
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
        const SizedBox(height: 12),
        const MadeByBrainCode(),
      ],
    );
  }
}

class TitleScreen extends StatefulWidget {
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
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  final _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  /// Capítulos con los índices de sus artículos (filtrados por la búsqueda).
  List<(String, List<int>)> _grupos() {
    final q = normalizar(_query.trim());
    final out = <(String, List<int>)>[];
    for (var i = widget.start; i < widget.start + widget.count; i++) {
      final a = widget.ley.articulos[i];
      if (q.isNotEmpty && !normalizar(a.id).contains(q) && !a.norm.contains(q)) continue;
      if (out.isEmpty || out.last.$1 != a.capitulo) out.add((a.capitulo, []));
      out.last.$2.add(i);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    final grupos = _grupos();
    final capitulos = {
      for (var i = widget.start; i < widget.start + widget.count; i++)
        widget.ley.articulos[i].capitulo
    }.where((c) => c.isNotEmpty).length;
    final total = grupos.fold(0, (n, g) => n + g.$2.length);

    return GlassScaffold(
      appBar: AppBar(title: Text(_tituloCorto(widget.titulo))),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Reveal(
                    child: Text(
                        _tituloNombre(widget.titulo).isEmpty
                            ? _tituloCorto(widget.titulo)
                            : _tituloNombre(widget.titulo),
                        style: TextStyle(
                            fontFamily: kSerif,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: t.text,
                            height: 1.2)),
                  ),
                  const SizedBox(height: 12),
                  Reveal(
                    index: 1,
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      _Stat(PhosphorIconsLight.article, '${widget.count} artículos'),
                      if (capitulos > 0)
                        _Stat(PhosphorIconsLight.stack,
                            '$capitulos capítulo${capitulos == 1 ? '' : 's'}'),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Reveal(
                    index: 2,
                    child: TextField(
                      controller: _q,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Filtrar por número o palabra',
                        prefixIcon: Icon(PhosphorIconsLight.magnifyingGlass, color: t.text3),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Borrar',
                                icon: const Icon(PhosphorIconsLight.x),
                                onPressed: () => setState(() {
                                  _q.clear();
                                  _query = '';
                                }),
                              ),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Reveal(
                    index: 3,
                    child: Row(children: [
                      Icon(PhosphorIconsLight.handTap, size: 16, color: t.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            _query.isEmpty
                                ? 'Toca un artículo para leerlo completo'
                                : '$total resultado${total == 1 ? '' : 's'} en este título',
                            style: TextStyle(fontSize: 13, color: t.text2)),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          if (grupos.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                child: Text('No hay artículos que coincidan con “$_query”.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: t.text2)),
              ),
            ),
          for (final g in grupos)
            SliverMainAxisGroup(slivers: [
              if (g.$1.isNotEmpty)
                SliverPersistentHeader(pinned: true, delegate: _ChapterHeader(g.$1)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                sliver: SliverList.builder(
                  itemCount: g.$2.length,
                  itemBuilder: (context, k) {
                    final i = g.$2[k];
                    return Padding(
                      key: ValueKey(i),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ScrollReveal(
                        child: _ArticleCard(
                          a: widget.ley.articulos[i],
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ArticleScreen(
                                  ley: widget.ley, index: i, highlight: _query))),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 28),
            sliver: SliverToBoxAdapter(child: MadeByBrainCode()),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Stat(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.glass,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: t.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: t.text2),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: t.text2)),
      ]),
    );
  }
}

/// Encabezado de capítulo que se queda fijo arriba mientras se recorren sus artículos.
class _ChapterHeader extends SliverPersistentHeaderDelegate {
  final String capitulo;
  _ChapterHeader(this.capitulo);

  static const _h = 58.0;
  @override
  double get minExtent => _h;
  @override
  double get maxExtent => _h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = Tok.of(context);
    final partes = capitulo.split(' · ');
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: overlapsContent ? t.glass : Colors.transparent,
            border: Border(
                bottom: BorderSide(color: overlapsContent ? t.border : Colors.transparent)),
          ),
          padding: const EdgeInsets.fromLTRB(22, 8, 20, 8),
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(partes.first.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: t.primary)),
              if (partes.length > 1)
                Text(partes.sublist(1).join(' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: t.text)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ChapterHeader old) => old.capitulo != capitulo;
}

/// Tarjeta de artículo: número completo en una etiqueta (sin cortes), vista
/// previa a todo lo ancho y una flecha que indica que se puede abrir.
class _ArticleCard extends StatelessWidget {
  final Articulo a;
  final VoidCallback onTap;
  const _ArticleCard({required this.a, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Tok.of(context);
    return PressableCard(
      onTap: onTap,
      semanticLabel: 'Abrir ${a.nombre}',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: t.primarySoft, borderRadius: BorderRadius.circular(8)),
                child: Text('Art. ${a.id}',
                    softWrap: false,
                    style: TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w700, color: t.primary)),
              ),
              const Spacer(),
              Text('Leer',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: t.text3)),
              const SizedBox(width: 4),
              Icon(PhosphorIconsLight.caretRight, size: 16, color: t.text3),
            ]),
            const SizedBox(height: 10),
            Text(a.parrafos.isEmpty ? 'Sin texto.' : a.parrafos.first,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14.5, color: t.text2, height: 1.45)),
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

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Ley Federal del Trabajo'),
        actions: [
          IconButton(
            tooltip: 'Reducir texto',
            onPressed: _scale > .85 ? () => setState(() => _scale -= .1) : null,
            icon: const Icon(PhosphorIconsLight.magnifyingGlassMinus),
          ),
          IconButton(
            tooltip: 'Aumentar texto',
            onPressed: _scale < 1.6 ? () => setState(() => _scale += .1) : null,
            icon: const Icon(PhosphorIconsLight.magnifyingGlassPlus),
          ),
          IconButton(
            tooltip: 'Compartir',
            onPressed: () => Native.share(
                '${a.nombre} de la Ley Federal del Trabajo\n\n'
                '${a.parrafos.join('\n\n')}\n\n'
                'Última reforma DOF ${ley.versionLegible}. Fuente: Cámara de Diputados.'),
            icon: const Icon(PhosphorIconsLight.export),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: BottomActionBar(children: [
        OutlinedButton.icon(
          onPressed: _i > 0 ? () => _go(_i - 1) : null,
          icon: const Icon(PhosphorIconsLight.caretLeft),
          label: Text(_i > 0 ? 'Art. ${ley.articulos[_i - 1].id}' : 'Inicio'),
        ),
        OutlinedButton.icon(
          onPressed: _i < ley.articulos.length - 1 ? () => _go(_i + 1) : null,
          iconAlignment: IconAlignment.end,
          icon: const Icon(PhosphorIconsLight.caretRight),
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
                  fontFamily: kSerif, fontSize: 32, fontWeight: FontWeight.w600, color: t.text)),
          const SizedBox(height: 10),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  height: 3,
                  width: 48,
                  decoration: BoxDecoration(
                      color: t.accent, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Reveal(
            key: ValueKey(_i),
            child: Glass(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                ],
              ),
            ),
          ),
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
