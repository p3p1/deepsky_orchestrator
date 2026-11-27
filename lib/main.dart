// =====================================================================
// DeepSky Orchestrator v2 — Flutter (mockup v2)
// FRA400 400mm f/5.6 + ASI2600MC Pro APS-C, riduttore 0.8x opzionale
//
// Layout responsive: >=600dp -> two-pane master-detail (Z Fold aperto),
// <600dp -> lista + scheda a pieno schermo (Fold chiuso / telefono).
// =====================================================================

import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const DeepSkyApp());

// ============================== DATI =================================

class Dso {
  final String name, type, con;
  final double raH, dec, mag, sizeMin; // sizeMin = diam. maggiore (arcmin)
  const Dso(this.name, this.type, this.con, this.raH, this.dec, this.mag, this.sizeMin);

  String get label => switch (type) {
        'BN' || 'SNR' || 'PN' => 'db', // dual-band
        'OC' || 'GC' => 'uv', // uv/ir cut
        _ => 'no', // nessuno (galassie)
      };
  int get bestMonth {
    const sunRa = [18.8, 20.9, 22.9, 0.9, 2.7, 4.7, 6.5, 8.6, 10.7, 12.8, 14.7, 16.8];
    var best = 0, bd = 99.0;
    for (var m = 0; m < 12; m++) {
      final d = ((raH - sunRa[m]) % 24 + 24) % 24 - 12;
      if (d.abs() < bd.abs()) { bd = d; best = m; }
    }
    return best;
  }
}

const _cat = '''
M1|SNR|Tau|5.96|22.0|8.4|6
M2|GC|Aqr|21.56|-0.8|6.5|16
M3|GC|CVn|13.70|28.4|6.2|18
M4|GC|Sco|16.39|-26.5|5.9|26
M5|GC|Ser|15.31|2.1|5.7|23
M6|OC|Sco|17.67|-32.3|4.2|25
M7|OC|Sco|17.90|-34.8|3.3|80
M8|BN|Sgr|18.06|-24.4|6.0|90
M9|GC|Oph|17.32|-18.5|7.7|12
M10|GC|Oph|16.95|-4.1|6.6|20
M11|OC|Sct|18.85|-6.3|5.8|14
M12|GC|Oph|16.79|-2.0|6.7|15
M13|GC|Her|16.70|36.5|5.8|20
M14|GC|Oph|17.63|-3.2|7.6|11
M15|GC|Peg|21.50|12.2|6.2|18
M16|BN|Ser|18.31|-13.8|6.0|35
M17|BN|Sgr|18.35|-16.2|6.0|30
M18|OC|Sgr|18.33|-17.1|6.9|9
M19|GC|Oph|17.04|-26.3|6.8|17
M20|BN|Sgr|18.04|-23.0|6.3|28
M21|OC|Sgr|18.08|-22.5|5.9|13
M22|GC|Sgr|18.61|-23.9|5.1|24
M23|OC|Sgr|17.95|-19.0|5.5|27
M24|OC|Sgr|18.28|-18.5|4.6|120
M25|OC|Sgr|18.53|-19.3|4.6|32
M27|PN|Vul|19.99|22.7|7.4|8
M28|GC|Sgr|18.41|-26.6|6.8|11
M29|OC|Cyg|20.40|38.5|6.6|7
M31|GAL|And|0.71|41.3|3.4|190
M33|GAL|Tri|1.56|30.7|5.7|70
M34|OC|Per|2.70|42.7|5.2|35
M35|OC|Gem|5.15|24.3|5.1|28
M36|OC|Aur|5.61|34.1|6.0|12
M37|OC|Aur|5.87|32.6|5.6|24
M38|OC|Aur|5.48|35.9|6.4|21
M39|OC|Cyg|21.53|48.4|4.6|31
M41|OC|CMa|6.77|-20.7|4.5|38
M42|BN|Ori|5.59|-5.4|4.0|85
M44|OC|Cnc|8.67|20.0|3.1|95
M45|OC|Tau|3.78|24.1|1.6|110
M46|OC|Pup|7.70|-14.8|6.0|27
M47|OC|Pup|7.61|-14.5|4.4|30
M48|OC|Hya|8.23|-5.8|5.5|54
M50|OC|Mon|7.05|-8.4|5.9|16
M51|GAL|CVn|13.50|47.2|8.4|11
M52|OC|Cas|23.40|61.6|6.9|13
M53|GC|Com|13.22|18.2|7.6|13
M55|GC|Sgr|19.67|-31.0|6.3|19
M57|PN|Lyr|18.89|33.0|8.8|1.4
M63|GAL|CVn|13.26|42.0|8.6|10
M64|GAL|Com|12.95|21.7|8.5|9
M65|GAL|Leo|11.31|13.1|9.3|10
M66|GAL|Leo|11.34|13.0|8.9|9
M76|PN|Per|1.71|51.6|10.1|2.7
M78|BN|Ori|5.78|0.1|8.3|8
M81|GAL|UMa|9.93|69.1|6.9|21
M82|GAL|UMa|9.93|69.7|8.4|11
M83|GAL|Hya|13.62|-29.9|7.5|11
M92|GC|Her|17.29|43.1|6.4|14
M94|GAL|CVn|14.03|41.4|8.2|7
M97|PN|UMa|11.25|55.0|9.9|3
M101|GAL|UMa|14.05|54.4|7.9|22
M103|OC|Cas|1.56|60.7|7.4|6
M104|GAL|Vir|12.67|-11.6|8.0|9
M106|GAL|CVn|12.32|47.3|8.4|19
M108|GAL|UMa|11.19|55.7|10.0|8
M109|GAL|UMa|11.96|55.4|9.8|7
M110|GAL|And|0.67|43.3|8.1|20
NGC281|BN|Cas|0.88|56.6|7.4|35
NGC457|OC|Cas|1.32|58.3|6.4|20
NGC869|OC|Per|2.32|57.1|4.3|30
NGC884|OC|Per|2.35|57.1|4.4|30
NGC891|GAL|And|2.38|42.4|9.9|13
NGC1333|BN|Per|3.48|31.4|5.6|7
NGC1499|BN|Per|4.03|36.6|5.0|160
NGC2244|OC|Mon|6.54|5.0|4.8|80
NGC2264|OC|Mon|6.69|9.9|3.9|20
NGC2403|GAL|Cam|7.59|65.7|8.4|22
NGC253|GAL|Scl|0.79|-25.3|7.1|27
NGC4565|GAL|Com|12.60|26.0|9.6|16
NGC4631|GAL|CVn|12.71|32.5|9.2|16
NGC6543|PN|Dra|17.98|66.6|8.1|0.4
NGC6826|PN|Cyg|19.75|61.6|8.8|0.8
NGC6888|BN|Cyg|20.20|38.4|10.0|22
NGC6992|SNR|Cyg|20.94|31.7|9.0|120
NGC7000|BN|Cyg|20.98|44.3|4.5|120
NGC7009|PN|Aqr|21.07|-11.4|8.0|0.7
NGC7293|PN|Aqr|22.50|-20.8|7.3|15
NGC7635|BN|Cas|23.34|61.2|10.5|15
NGC7331|GAL|Peg|22.37|34.4|9.5|11
NGC7789|OC|Cas|23.96|56.7|6.7|25
IC5070|BN|Cyg|20.86|44.2|8.0|120
IC1805|BN|Cas|2.55|61.3|6.5|150
IC1848|BN|Cas|2.87|60.4|6.5|150
Sh2-155|BN|Cep|22.98|57.8|7.7|50
NGC7023|BN|Cep|21.03|68.2|13.0|18
NGC7822|BN|Cep|0.06|68.6|7.7|60
NGC1514|PN|Tau|4.16|30.5|9.8|2
NGC2024|BN|Ori|5.68|-1.9|7.0|30
NGC2174|BN|Ori|6.16|20.5|6.8|40
IC434|BN|Ori|5.68|-2.4|9.0|60
Caldwell14|OC|Cyg|19.62|37.2|3.8|60
Abell33|PN|Hya|9.65|-12.6|12.2|3
''';

final catalog =
    _cat.trim().split('\n').map((l) {
      final p = l.split('|');
      return Dso(p[0], p[1], p[2], double.parse(p[3]), double.parse(p[4]),
          double.parse(p[5]), double.parse(p[6]));
    }).toList();

const typeNames = {
  'BN': 'Nebulosa', 'SNR': 'Supernova rem.', 'PN': 'Planetaria',
  'OC': 'Ammasso aperto', 'GC': 'Ammasso glob.', 'GAL': 'Galassia',
};
const filterNames = {'db': 'Dual-band', 'uv': 'UV/IR cut', 'no': 'Nessuno'};
const months = ['Gen','Feb','Mar','Apr','Mag','Giu','Lug','Ago','Set','Ott','Nov','Dic'];

// =========================== SETUP / SCORING ==========================

class RigConfig {
  final double focal, fRatio, reducer; // reducer 1.0 = nessuno
  const RigConfig({this.focal = 400, this.fRatio = 5.6, this.reducer = 1.0});
  RigConfig withReducer(double r) =>
      RigConfig(focal: focal, fRatio: fRatio, reducer: r);
  double get effFocal => focal * reducer;
  double get effFratio => fRatio * reducer;
  // ASI2600MC Pro: 23.5 x 15.7 mm, pixel 3.76 um
  double get fovW => 2 * atan(23.5 / (2 * effFocal)) * 180 / pi;
  double get fovH => 2 * atan(15.7 / (2 * effFocal)) * 180 / pi;
  double get sampling => 206.265 * 3.76 / effFocal; // "/px
}

/// Punteggio fattibilita' 0..10 per una data configurazione.
/// Pesi: 30% match campo, 30% luminosita' (mag), 20% risolvibilita',
/// 20% difficolta' di tipo.
double score(Dso o, RigConfig rig) {
  if (o.sizeMin <= 0) return 5.0;
  final objDeg = o.sizeMin / 60.0;
  final h = rig.fovH, w = rig.fovW;

  // match campo (0..1): ideale riempimento 20..90%
  final fill = objDeg / h;
  final fieldScore = fill > 1.0 ? max(0.0, 1.0 - (fill - 1.0)) : (fill < 0.08 ? 0.5 : 1.0);

  // luminosita': mag 1 -> 1.0, mag 12 -> 0.1
  final magScore = ((12 - o.mag) / 10).clamp(0.05, 1.0);

  // risolvibilita': dimensione apparente in pixel (sensore 6248 px larghezza)
  final px = o.sizeMin / 60.0 / w * 6248;
  final resScore = (px / 400).clamp(0.05, 1.0);

  // difficolta' tipo
  final typeScore = switch (o.type) {
    'OC' || 'GC' => 0.95,
    'GAL' => 0.75,
    'PN' => 0.6,
    'BN' => 0.65,
    'SNR' => 0.5,
    _ => 0.5,
  };

  return ((0.30 * fieldScore + 0.30 * magScore + 0.20 * resScore + 0.20 * typeScore) * 10);
}

/// esposizione suggerita (s) riferita a 180s @ f/5.6
double expoS(RigConfig rig) => (180 / pow(rig.effFratio / 5.6, 2)).clamp(15, 900).toDouble();

// ================================ APP =================================

class DeepSkyApp extends StatelessWidget {
  const DeepSkyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'DeepSky Orchestrator',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF6D4AFF), brightness: Brightness.dark),
        home: const Root(),
      );
}

class Filters {
  String? type;       // 'BN','SNR','PN','OC','GC','GAL'
  String? filterKey;  // 'db','uv','no'
  String fovMode = 'both'; // 'both','native','reduced','mosaicOK'
  int? month;         // 0..11
  SortBy sort = SortBy.score;
  double minScore = 0;
}

enum SortBy { score, name, size, ra, dec }

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  var rig = const RigConfig();
  var filters = Filters();
  Dso? selected;
  bool showDetailPhone = false;

  List<Dso> get filtered {
    var l = catalog.where((o) {
      if (filters.type != null && o.type != filters.type) return false;
      if (filters.filterKey != null && o.label != filters.filterKey) return false;
      if (filters.month != null && o.bestMonth != filters.month) return false;
      if (score(o, rig) < filters.minScore) return false;
      // FOV mode
      if (filters.fovMode != 'both') {
        final sNative = score(o, const RigConfig());
        final sRed = score(o, rig.withReducer(0.8));
        switch (filters.fovMode) {
          case 'mosaicOK':
            if (o.sizeMin / 60 > rig.fovH) return false;
          case 'native':
            if (sNative < 4) return false;
          case 'reduced':
            if (sRed < 4) return false;
          default:
            break;
        }
      }
      return true;
    }).toList();
    int cmp(Dso a, Dso b) => switch (filters.sort) {
          SortBy.score => score(b, rig).compareTo(score(a, rig)),
          SortBy.name => a.name.compareTo(b.name),
          SortBy.size => b.sizeMin.compareTo(a.sizeMin),
          SortBy.ra => a.raH.compareTo(b.raH),
          SortBy.dec => b.dec.compareTo(a.dec),
        };
    l.sort(cmp);
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 600;
    selected ??= filtered.isNotEmpty ? filtered.first : null;
    return Scaffold(
      body: wide
          ? Row(children: [
              SizedBox(width: 340, child: _ListPane(root: this, master: true)),
              const VerticalDivider(width: 1),
              Expanded(child: selected != null ? _DetailPane(root: this, compact: false) : const Center(child: Text('Seleziona un oggetto'))),
            ])
          : showDetailPhone && selected != null
              ? _DetailPane(root: this, compact: true)
              : _ListPane(root: this, master: false),
      bottomNavigationBar: wide ? null : _BottomNav(root: this),
    );
  }
}

// --------------------------- TOOLBAR FILTRI --------------------------

Widget chip(BuildContext c, String label, bool active, VoidCallback onTap) =>
    Padding(padding: const EdgeInsets.only(right: 6), child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: active,
        onSelected: (_) => onTap()));

class _Toolbar extends StatelessWidget {
  final _RootState root;
  const _Toolbar({required this.root});
  @override
  Widget build(BuildContext context) {
    final f = root.filters;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(children: [
          const Text('Tipo  ', style: TextStyle(fontSize: 10, color: Colors.white54)),
          chip(context, 'Tutti', f.type == null, () => root.setState(() => f.type = null)),
          for (final e in typeNames.entries)
            chip(context, e.key, f.type == e.key, () => root.setState(() => f.type = e.key)),
        ]),
        Wrap(children: [
          const Text('Filtro  ', style: TextStyle(fontSize: 10, color: Colors.white54)),
          chip(context, 'Tutti', f.filterKey == null, () => root.setState(() => f.filterKey = null)),
          for (final e in filterNames.entries)
            chip(context, e.value, f.filterKey == e.key, () => root.setState(() => f.filterKey = e.key)),
        ]),
        Wrap(children: [
          const Text('FOV  ', style: TextStyle(fontSize: 10, color: Colors.white54)),
          for (final m in const [('Entrambi','both'),('400mm','native'),('320mm rid.','reduced'),('mosaic ok','mosaicOK')])
            chip(context, m.$1, f.fovMode == m.$2, () => root.setState(() => f.fovMode = m.$2)),
        ]),
        Wrap(children: [
          const Text('Mese  ', style: TextStyle(fontSize: 10, color: Colors.white54)),
          chip(context, 'Tutti', f.month == null, () => root.setState(() => f.month = null)),
          for (var m = 0; m < 12; m++)
            chip(context, months[m], f.month == m, () => root.setState(() => f.month = m)),
        ]),
        Wrap(children: [
          const Text('Ordina  ', style: TextStyle(fontSize: 10, color: Colors.white54)),
          for (final s in const [(SortBy.score,'Punteggio'),(SortBy.name,'Sigla'),(SortBy.size,'Dim.'),(SortBy.ra,'AR'),(SortBy.dec,'Dec')])
            chip(context, s.$2, f.sort == s.$1, () => root.setState(() => f.sort = s.$1)),
        ]),
        Row(children: [
          const Text('Punteggio min', style: TextStyle(fontSize: 10, color: Colors.white54)),
          Expanded(child: Slider(
              value: f.minScore, min: 0, max: 10, divisions: 20,
              label: f.minScore.toStringAsFixed(1),
              onChanged: (v) => root.setState(() => f.minScore = v))),
          Text('>= ${f.minScore.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 11, color: Color(0xFFB39DFF), fontWeight: FontWeight.bold)),
        ]),
      ])),
    );
  }
}

// ------------------------------ LISTA --------------------------------

class _ListPane extends StatelessWidget {
  final _RootState root;
  final bool master;
  const _ListPane({required this.root, required this.master});
  @override
  Widget build(BuildContext context) {
    final list = root.filtered;
    return Column(children: [
      AppBar(title: Text('Catalogo · ${list.length}')),
      _Toolbar(root: root),
      Expanded(child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          final o = list[i];
          final sc = score(o, root.rig);
          final nat = const RigConfig();
          final red = root.rig.withReducer(0.8);
          final fitNat = o.sizeMin / 60 <= nat.fovH;
          final fitRed = o.sizeMin / 60 <= red.fovH;
          final sel = root.selected?.name == o.name;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: sel ? Theme.of(context).colorScheme.primaryContainer : null,
            child: ListTile(
              dense: true,
              onTap: () => root.setState(() {
                root.selected = o;
                root.showDetailPhone = !master;
              }),
              title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text('${o.name} · ${o.con}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                Text(sc.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: sc >= 7 ? Colors.greenAccent : sc >= 5 ? Colors.orangeAccent : Colors.redAccent)),
              ]),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${typeNames[o.type]} · mag ${o.mag} · ${o.sizeMin}\u2032 · ${months[o.bestMonth]}',
                    style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 3),
                Wrap(spacing: 4, children: [
                  _miniBadge(fitNat ? '✔ 400mm' : (o.sizeMin/60 <= 2*nat.fovH ? '▣ mos. 400' : '✖ no'), fitNat),
                  _miniBadge(fitRed ? '✔ 320mm' : (o.sizeMin/60 <= 2*red.fovH ? '▣ mos. 320' : '✖ no'), fitRed),
                  _miniBadge(filterNames[o.label]!, true, faded: o.label == 'no'),
                ]),
              ]),
            ),
          );
        },
      )),
    ]);
  }
}

Widget _miniBadge(String t, bool ok, {bool faded = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
        color: faded ? Colors.white12 : ok ? Colors.green.withOpacity(.15) : Colors.orange.withOpacity(.15),
        borderRadius: BorderRadius.circular(4)),
    child: Text(t, style: const TextStyle(fontSize: 9, color: Colors.white70)));

// ----------------------------- DETTAGLIO ------------------------------

class _DetailPane extends StatelessWidget {
  final _RootState root;
  final bool compact;
  const _DetailPane({required this.root, required this.compact});
  @override
  Widget build(BuildContext context) {
    final o = root.selected!;
    final nat = const RigConfig();
    final red = root.rig.withReducer(0.8);
    final sc = score(o, root.rig);

    Widget frameBox(RigConfig r, String title, Color accent) {
      final objDeg = o.sizeMin / 60;
      final fill = (objDeg / r.fovH).clamp(0.03, 1.2);
      final fits = objDeg <= r.fovH;
      final marginArcmin = fits ? (r.fovH - objDeg) * 60 : 0.0;
      return Expanded(child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: accent.withOpacity(.5)), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Text('${r.fovW.toStringAsFixed(2)}° × ${r.fovH.toStringAsFixed(2)}°',
              style: const TextStyle(fontSize: 9, color: Colors.white54)),
          const SizedBox(height: 6),
          AspectRatio(aspectRatio: r.fovW / r.fovH, child: Container(
            decoration: BoxDecoration(color: Colors.black26, border: Border.all(color: accent), borderRadius: BorderRadius.circular(5)),
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: fill.clamp(0.05, 1.0),
              heightFactor: fill.clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(color: accent.withOpacity(.25), border: Border.all(color: accent), borderRadius: BorderRadius.circular(4)),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2),
                child: Text(o.name, style: const TextStyle(fontSize: 9), textAlign: TextAlign.center)))),
          ),
          const SizedBox(height: 5),
          Text('riempimento ${(fill * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 10)),
          Text(fits ? 'margine ${marginArcmin.round()}\u2032' : 'serve mosaic',
              style: TextStyle(fontSize: 10, color: fits ? Colors.greenAccent : Colors.pinkAccent)),
        ]),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        leading: compact ? BackButton(onPressed: () => root.setState(() => root.showDetailPhone = false)) : null,
        title: Text('${o.name} — ${o.con}', style: const TextStyle(fontSize: 16))),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Center(child: Column(children: [
          Text(sc.toStringAsFixed(1), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
              color: sc >= 7 ? Colors.greenAccent : sc >= 5 ? Colors.orangeAccent : Colors.redAccent)),
          const Text('punteggio fattibilità /10', style: TextStyle(fontSize: 11, color: Colors.white54)),
        ])),
        const SizedBox(height: 10),
        _kv('Tipo', typeNames[o.type]!), _kv('Magnitudine', o.mag.toString()),
        _kv('Dimensione', '${o.sizeMin}\u2032'),
        _kv('AR / Dec', '${o.raH.floor()}h ${((o.raH % 1) * 60).round()}m / ${o.dec >= 0 ? '+' : ''}${o.dec.toStringAsFixed(1)}°'),
        _kv('Miglior mese', months[o.bestMonth]),
        const Divider(height: 24),
        const Text('INQUADRATURA — oggetto vs FOV', style: TextStyle(fontSize: 11, letterSpacing: 1, color: Color(0xFFB39DFF), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          frameBox(nat, 'SENZA riduttore · 400mm f/5.6', const Color(0xFF8A6BFF)),
          const SizedBox(width: 10),
          frameBox(red, 'CON riduttore 0.8× · 320mm f/4.5', const Color(0xFF7CC4EE)),
        ])),
        const SizedBox(height: 6),
        Text('scala: ${nat.sampling.toStringAsFixed(2)}\u2033/px (400mm) · ${red.sampling.toStringAsFixed(2)}\u2033/px (320mm)',
            style: const TextStyle(fontSize: 10, color: Colors.white38)),
        const Divider(height: 24),
        const Text('FILTRO CONSIGLIATO', style: TextStyle(fontSize: 11, letterSpacing: 1, color: Color(0xFFB39DFF), fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF6D4AFF)), borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(filterNames[o.label]!, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(switch (o.label) {
              'db' => 'Oggetto a emissione (Hα/OIII): il dual-band massimizza contrasto e sfrutta il cielo con la OSC.',
              'uv' => 'Sorgente stellare: UV/IR cut per stelle nette e focus stabile, nessuna perdita di segnale.',
              _ => 'Continuum spettrale: nessun filtro, il dual-band spegnerebbe le galassie.',
            }, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          ]),
        ),
        const Divider(height: 24),
        const Text('PIANO DI RIPRESA', style: TextStyle(fontSize: 11, letterSpacing: 1, color: Color(0xFFB39DFF), fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _kv('Esposizione', '${expoS(nat).round()} s × 60 (400mm)'),
        _kv('Esposizione rid.', '${expoS(red).round()} s × 90 (320mm f/4.5)'),
        _kv('Gain / Offset', '100 / 50'),
        _kv('Dithering', 'ogni 2 frame'),
      ]),
    );
  }
}

Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(k, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                   Text(v, style: const TextStyle(fontSize: 12))]));

// ------------------------------ NAV -----------------------------------

class _BottomNav extends StatelessWidget {
  final _RootState root;
  const _BottomNav({required this.root});
  @override
  Widget build(BuildContext context) => NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Catalogo'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Filtri'),
          NavigationDestination(icon: Icon(Icons.dark_mode_outlined), label: 'Notte'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Setup'),
        ],
      );
}
