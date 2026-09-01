import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/services/whatsapp_launcher.dart';

void main() {
  test('buildWhatsAppUri limpia espacios y guiones', () {
    expect(buildWhatsAppUri('55 1234-5678'), 'https://wa.me/5512345678');
  });

  test('buildWhatsAppUri conserva el signo + inicial', () {
    expect(buildWhatsAppUri('+52 55 1234 5678'), 'https://wa.me/+525512345678');
  });
}
