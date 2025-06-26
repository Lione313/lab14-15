import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io show File;

import '../../models/product_model.dart';
import '../../services/cloudinary_service.dart';
import '../../viewmodels/products_view_model.dart';

class EditProductView extends StatefulWidget {
  final ProductModel producto;

  const EditProductView({super.key, required this.producto});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late DateTime _fechaVencimiento;

  io.File? _imageFile;
  Uint8List? _webImageBytes;
  XFile? _pickedFile;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _descripcionController = TextEditingController(text: widget.producto.descripcion);
    _precioController = TextEditingController(text: widget.producto.precio.toString());
    _fechaVencimiento = widget.producto.fechaVencimiento;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      setState(() {
        _fechaVencimiento = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _pickedFile = picked;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _webImageBytes = bytes);
      } else {
        setState(() => _imageFile = io.File(picked.path));
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      String? newImageUrl;

      final cloudinary = CloudinaryService();

      if (kIsWeb && _webImageBytes != null && _pickedFile != null) {
        newImageUrl = await cloudinary.uploadImage(
          webImageBytes: _webImageBytes,
          fileName: _pickedFile!.name,
        );
      } else if (!kIsWeb && _imageFile != null) {
        newImageUrl = await cloudinary.uploadImage(imageFile: _imageFile);
      }

      final updatedProduct = ProductModel(
        id: widget.producto.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        fechaVencimiento: _fechaVencimiento,
        precio: double.parse(_precioController.text),
        backgroundImg: newImageUrl ?? widget.producto.backgroundImg,
      );

      await Provider.of<ProductsViewModel>(context, listen: false)
          .updateProducto(updatedProduct);

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreview;

    if (kIsWeb && _webImageBytes != null) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(_webImageBytes!, height: 180, fit: BoxFit.cover),
      );
    } else if (!kIsWeb && _imageFile != null) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(_imageFile!, height: 180, fit: BoxFit.cover),
      );
    } else if (widget.producto.backgroundImg.isNotEmpty) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(widget.producto.backgroundImg,
            height: 180, fit: BoxFit.cover),
      );
    } else {
      imagePreview = Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(child: Text('No hay imagen del producto')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modificar información',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio (S/)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Ingrese el precio' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vence: ${_fechaVencimiento.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              imagePreview,
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Cambiar imagen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Guardando...' : 'Guardar Cambios',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveChanges,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
