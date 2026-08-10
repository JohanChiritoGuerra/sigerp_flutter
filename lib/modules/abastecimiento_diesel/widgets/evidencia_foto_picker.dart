import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EvidenciaFotoPicker extends StatelessWidget {
  final File? foto;
  final ValueChanged<File?> onChanged;

  const EvidenciaFotoPicker({super.key, required this.foto, required this.onChanged});

  Future<void> _seleccionar(BuildContext context) async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (origen == null) return;

    final picker = ImagePicker();
    final archivo = await picker.pickImage(source: origen, imageQuality: 80);
    if (archivo != null) {
      onChanged(File(archivo.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto de evidencia',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _seleccionar(context),
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            // 4:3 da una vista previa notoriamente más alta que el rectángulo
            // angosto anterior (140dp fijo), sin necesitar scroll interno:
            // la pantalla ya se desplaza completa dentro de un SingleChildScrollView.
            aspectRatio: 4 / 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.grey[100],
                image: foto != null
                    ? DecorationImage(image: FileImage(foto!), fit: BoxFit.contain)
                    : null,
              ),
              child: foto == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[500]),
                        const SizedBox(height: 8),
                        Text('Agregar foto', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    )
                  : Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: GestureDetector(
                          onTap: () => onChanged(null),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
