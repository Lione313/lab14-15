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

  io.File? _imageFile; // Solo para móviles y desktop
  Uint8List? _webImageBytes; // Solo para web

  XFile? _pickedFile; // Común para ambos

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
  if (_formKey.currentState!.validate() && _fechaVencimiento != null) {
    // Verificar si hay imagen (web o móvil)
    final tieneImagen = (!kIsWeb && _imageFile != null) || (kIsWeb && _webImageBytes != null);

    if (!tieneImagen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una imagen para el producto.')),
      );
      return;
    }

    final viewModel = Provider.of<ProductsViewModel>(context, listen: false);

    await viewModel.addProducto(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fechaVencimiento: _fechaVencimiento!,
      precio: double.parse(_precioController.text),
      imageFile: kIsWeb ? null : _imageFile,
      webImageBytes: kIsWeb ? _webImageBytes : null,
      webFileName: kIsWeb && _pickedFile != null ? _pickedFile!.name : null,
    );

    if (mounted) Navigator.pop(context);
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
      imagePreview = Image.memory(_webImageBytes!, height: 150);
    } else if (_imageFile != null) {
      imagePreview = Image.file(_imageFile!, height: 150);
    } else {
      imagePreview = const Text('No se seleccionó imagen');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Ingrese el nombre' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Ingrese una descripción' : null,
              ),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
                validator: (value) => value!.isEmpty ? 'Ingrese el precio' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_fechaVencimiento == null
                        ? 'Seleccionar fecha de vencimiento'
                        : 'Vence: ${_fechaVencimiento!.toLocal().toString().split(' ')[0]}'),
                  ),
                  IconButton(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              imagePreview,
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Guardar Producto'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
