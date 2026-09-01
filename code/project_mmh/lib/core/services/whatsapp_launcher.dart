import 'package:url_launcher/url_launcher.dart';

/// Construye el enlace `wa.me` a partir de un teléfono capturado libremente
/// (puede traer espacios o guiones); conserva el `+` inicial si existe.
String buildWhatsAppUri(String telefono) {
  final digits = telefono.replaceAll(RegExp(r'[^0-9+]'), '');
  return 'https://wa.me/$digits';
}

Future<void> launchWhatsApp(String telefono) async {
  final uri = Uri.parse(buildWhatsAppUri(telefono));
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
