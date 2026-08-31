// test/design_system_guardrail_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

class GuardrailHit {
  GuardrailHit(this.file, this.line, this.rule, this.hint);
  final String file;
  final int line;
  final String rule;
  final String hint;
  @override
  String toString() => '$file:$line — $rule → $hint';
}

const _rules = <({String re, String rule, String hint})>[
  (
    re: r'TextStyle\([^;]*fontSize:',
    rule: 'TextStyle con fontSize',
    hint: 'usa un rol de AppText o theme.textTheme',
  ),
  (
    re: r'Color\(0x|(?<![\w.])Colors\.(?!transparent\b)',
    rule: 'literal de color',
    hint: 'usa ColorScheme / context.semantic / ClinicPalette',
  ),
  (
    re: r'showModalBottomSheet\(|showCupertinoModalPopup\(',
    rule: 'hoja modal directa',
    hint: 'usa showAppSheet',
  ),
  (
    re: r'CupertinoSliverNavigationBar|(?<![\w])AppBar\(',
    rule: 'encabezado a mano',
    hint: 'usa AppScaffold',
  ),
  (
    re: r'_getInputDecoration',
    rule: '_getInputDecoration',
    hint: 'usa AppTextField',
  ),
];

List<GuardrailHit> scanSource(String path, String content) {
  final lines = content.split('\n');
  final hits = <GuardrailHit>[];
  for (var i = 0; i < lines.length; i++) {
    final prev = i > 0 ? lines[i - 1] : '';
    if (prev.contains('design-system-ignore:')) continue;
    for (final r in _rules) {
      if (RegExp(r.re).hasMatch(lines[i])) {
        hits.add(GuardrailHit(path, i + 1, r.rule, r.hint));
      }
    }
    // Sub-regla: `fontSize:` en línea continuada dentro de un TextStyle(...)
    // partido en varias líneas (el regex por línea de arriba no lo ve).
    if (RegExp(r'^\s*fontSize:\s').hasMatch(lines[i])) {
      // El `design-system-ignore` puede estar sobre esta línea (ya cubierto por
      // el `continue` de arriba) o sobre la apertura del `TextStyle(` que la
      // envuelve: buscamos hacia atrás esa apertura y miramos la línea previa.
      var exempt = false;
      for (var j = i - 1; j >= 0 && j >= i - 12; j--) {
        if (lines[j].contains('TextStyle(')) {
          exempt = j > 0 && lines[j - 1].contains('design-system-ignore:');
          break;
        }
      }
      if (!exempt) {
        hits.add(
          GuardrailHit(
            path,
            i + 1,
            'TextStyle con fontSize',
            'usa un rol de AppText o theme.textTheme',
          ),
        );
      }
    }
  }
  return hits;
}

void main() {
  test('scanSource detecta cada patrón prohibido', () {
    final bad =
        File(
          'test/fixtures/design_system_guardrail/bad_example.dart.txt',
        ).readAsStringSync();
    final rules = scanSource('bad', bad).map((h) => h.rule).toSet();
    expect(
      rules,
      containsAll(<String>[
        'TextStyle con fontSize',
        'literal de color',
        'hoja modal directa',
        'encabezado a mano',
        '_getInputDecoration',
      ]),
    );
  });

  test('detecta fontSize en TextStyle partido en varias líneas', () {
    final bad =
        File(
          'test/fixtures/design_system_guardrail/bad_example.dart.txt',
        ).readAsStringSync();
    final fontSizeHits =
        scanSource(
          'bad',
          bad,
        ).where((h) => h.rule == 'TextStyle con fontSize').toList();
    // La línea inline + la línea continuada del TextStyle envuelto.
    expect(fontSizeHits.length, greaterThanOrEqualTo(2));
    expect(
      fontSizeHits.any((h) => h.line == 7),
      isTrue,
      reason:
          'debe marcar la línea `fontSize:` continuada del TextStyle envuelto',
    );
  });

  test('design-system-ignore exime la línea siguiente', () {
    final exempt =
        File(
          'test/fixtures/design_system_guardrail/exempt_example.dart.txt',
        ).readAsStringSync();
    expect(scanSource('exempt', exempt), isEmpty);
  });

  test('lib/features/ está limpio', () {
    final dir = Directory('lib/features');
    final hits = <GuardrailHit>[];
    var exemptions = 0;
    for (final e in dir.listSync(recursive: true).whereType<File>()) {
      if (!e.path.endsWith('.dart')) continue;
      if (e.path.endsWith('.g.dart') || e.path.endsWith('.freezed.dart')) {
        continue;
      }
      if (e.path.contains('/features/dev/')) continue;
      final content = e.readAsStringSync();
      exemptions += 'design-system-ignore:'.allMatches(content).length;
      hits.addAll(scanSource(e.path, content));
    }
    if (exemptions > 0) {
      // ignore: avoid_print
      print('design-system-ignore activos: $exemptions');
    }
    expect(
      exemptions,
      lessThanOrEqualTo(24),
      reason:
          'no añadir exenciones sin justificar; sube el tope conscientemente',
    );
    expect(hits, isEmpty, reason: 'Patrones prohibidos:\n${hits.join('\n')}');
  });
}
