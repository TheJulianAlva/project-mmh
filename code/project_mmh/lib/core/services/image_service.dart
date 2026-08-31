import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// Gestiona la selección y el almacenamiento local de imágenes de pacientes.
///
/// Las rutas se persisten en la BD de forma **relativa**
/// (`patient_images/<expediente>/<uuid>.<ext>`) y se resuelven contra el
/// directorio de documentos en tiempo de lectura. Esto evita que las imágenes
/// se rompan cuando el contenedor de la app cambia de ruta (p. ej. tras una
/// actualización en iOS).
class ImageService {
  final ImagePicker _picker = ImagePicker();

  static const Uuid _uuid = Uuid();
  static const String _imagesRoot = 'patient_images';

  /// Ruta absoluta al directorio de documentos, cacheada en el arranque.
  static String? _appDocPath;

  /// Debe llamarse una vez en `main()` antes de renderizar imágenes.
  static Future<void> init() async {
    _appDocPath = (await getApplicationDocumentsDirectory()).path;
  }

  static Future<String> _root() async {
    return _appDocPath ??=
        (await getApplicationDocumentsDirectory()).path;
  }

  Future<XFile?> pickImage(ImageSource source) async {
    return await _picker.pickImage(source: source);
  }

  /// Guarda la imagen y devuelve una ruta **relativa** apta para persistir.
  Future<String> saveImage(XFile imageFile, String subDirectory) async {
    final String root = await _root();
    final String relDir = p.join(_imagesRoot, subDirectory);
    final Directory absDir = Directory(p.join(root, relDir));
    if (!await absDir.exists()) {
      await absDir.create(recursive: true);
    }

    final String fileName = '${_uuid.v4()}${p.extension(imageFile.path)}';
    final String relPath = p.join(relDir, fileName);
    await imageFile.saveTo(p.join(root, relPath));
    return relPath;
  }

  /// Normaliza una ruta almacenada a relativa respecto al directorio de
  /// documentos. Soporta datos legados guardados como ruta absoluta.
  static String toRelativePath(String storedPath) {
    for (final marker in ['$_imagesRoot/', '$_imagesRoot\\']) {
      final idx = storedPath.indexOf(marker);
      if (idx >= 0) return storedPath.substring(idx).replaceAll('\\', '/');
    }
    return storedPath;
  }

  /// Reescribe el segmento de expediente de una ruta almacenada
  /// (`patient_images/<oldSub>/x.jpg` → `patient_images/<newSub>/x.jpg`).
  /// Necesario al cambiar el número de expediente para que la BD siga
  /// apuntando a los archivos tras renombrar la carpeta.
  static String reparentPath(String storedPath, String oldSub, String newSub) {
    final rel = toRelativePath(storedPath);
    final from = '$_imagesRoot/$oldSub/';
    if (rel.startsWith(from)) {
      return '$_imagesRoot/$newSub/${rel.substring(from.length)}';
    }
    return rel;
  }

  /// Convierte una ruta almacenada (relativa o absoluta legada) en absoluta.
  static String resolvePath(String storedPath) {
    final root = _appDocPath;
    final rel = toRelativePath(storedPath);
    if (root == null || p.isAbsolute(rel)) return storedPath;
    return p.join(root, rel);
  }

  static File resolveFile(String storedPath) => File(resolvePath(storedPath));

  Future<void> deleteImage(String storedPath) async {
    final file = resolveFile(storedPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Borra el directorio completo de imágenes de un paciente.
  Future<void> deletePatientImages(String subDirectory) async {
    final String root = await _root();
    final dir = Directory(p.join(root, _imagesRoot, subDirectory));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Renombra el directorio de imágenes cuando cambia el id de expediente.
  /// Si ya existe una carpeta con el nuevo id (huérfana: la transacción de BD
  /// verificó que no hay paciente con ese id) se elimina antes de renombrar.
  Future<void> movePatientImages(String oldSub, String newSub) async {
    final String root = await _root();
    final oldDir = Directory(p.join(root, _imagesRoot, oldSub));
    if (!await oldDir.exists()) return;
    final newDir = Directory(p.join(root, _imagesRoot, newSub));
    if (await newDir.exists()) {
      await newDir.delete(recursive: true);
    }
    await oldDir.rename(newDir.path);
  }
}
