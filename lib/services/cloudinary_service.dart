import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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

 Future<String?> uploadImage(File imageFile) async {
  final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = _uploadPreset
    ..fields['folder'] = 'productosFlutter' 
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final resStr = await response.stream.bytesToString();
    final data = jsonDecode(resStr);
    return data['secure_url'];
  } else {
    print('Error al subir imagen: ${response.statusCode}');
    return null;
  }
}

}
