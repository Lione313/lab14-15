import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io show File;

import '../../viewmodels/products_view_model.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  DateTime? _fechaVencimiento;

  io.File? _imageFile;
  Uint8List? _webImageBytes;
  XFile? _pickedFile;

  bool _isSaving = false; // ✅ Evitar duplicados

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

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _fechaVencimiento = picked);
    }
  }

  void _saveProduct() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate() && _fechaVencimiento != null) {
      final tieneImagen =
          (!kIsWeb && _imageFile != null) || (kIsWeb && _webImageBytes != null);

      if (!tieneImagen) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe seleccionar una imagen para el producto.'),
          ),
        );
        return;
      }

      setState(() => _isSaving = true);

      final viewModel =
          Provider.of<ProductsViewModel>(context, listen: false);

      await viewModel.addProducto(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        fechaVencimiento: _fechaVencimiento!,
        precio: double.parse(_precioController.text),
        imageFile: kIsWeb ? null : _imageFile,
        webImageBytes: kIsWeb ? _webImageBytes : null,
        webFileName: kIsWeb && _pickedFile != null ? _pickedFile!.name : null,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreview;
    if (kIsWeb && _webImageBytes != null) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(_webImageBytes!, height: 180, fit: BoxFit.cover),
      );
    } else if (_imageFile != null) {
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(_imageFile!, height: 180, fit: BoxFit.cover),
      );
    } else {
      imagePreview = Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(child: Text('No se seleccionó imagen')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Nuevo Producto'),
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
                'Detalles del producto',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el nombre' : null,
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
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese el precio' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaVencimiento == null
                          ? 'Seleccionar fecha de vencimiento'
                          : 'Vence: ${_fechaVencimiento!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              imagePreview,
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar Imagen'),
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
                    _isSaving ? 'Guardando...' : 'Guardar Producto',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveProduct,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
