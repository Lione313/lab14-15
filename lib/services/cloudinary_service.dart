import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

// Import condicional
import 'dart:io' as io show File;
import 'dart:io' as io;


import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal() {
    _cloudinary = Cloudinary.fromCloudName(cloudName: _cloudName);
    _cloudinary.config.urlConfig.secure = true;
  }

  final String _cloudName = 'dijr92ntz';
  final String _uploadPreset = 'flutter';
  late final Cloudinary _cloudinary;

  Cloudinary get instance => _cloudinary;

  String getImageUrl(String publicId, {int width = 200, int height = 200}) {
    return (_cloudinary.image(publicId)
          ..transformation(Transformation()
            ..resize(Resize.crop()
              ..width(width)
              ..height(height))))
        .toString();
  }

  /// Soporta Web (Uint8List) y Móvil (File)
Future<String?> uploadImage({
  io.File? imageFile,
  Uint8List? webImageBytes,
  String? fileName,
}) async {
  final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  print('📤 Iniciando subida de imagen a Cloudinary...');
  print('🌐 URL destino: $url');

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = _uploadPreset
    ..fields['folder'] = 'productosFlutter';

  if (kIsWeb && webImageBytes != null && fileName != null) {
    print('🖼️ Plataforma: Web');
    print('📁 Nombre archivo web: $fileName');
    request.files.add(http.MultipartFile.fromBytes('file', webImageBytes, filename: fileName));
  } else if (!kIsWeb && imageFile != null) {
    print('📱 Plataforma: Móvil/Escritorio');
    print('📁 Path archivo local: ${imageFile.path}');
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
  } else {
    print('❌ No se proporcionó archivo válido para subir.');
    return null;
  }

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = jsonDecode(resStr);
      final uploadedUrl = data['secure_url'];
      print('✅ Imagen subida exitosamente. URL: $uploadedUrl');
      return uploadedUrl;
    } else {
      print('❌ Error al subir imagen. Código HTTP: ${response.statusCode}');
      final errorBody = await response.stream.bytesToString();
      print('🔍 Respuesta del servidor: $errorBody');
      return null;
    }
  } catch (e) {
    print('💥 Excepción al subir imagen: $e');
    return null;
  }
} 
}
