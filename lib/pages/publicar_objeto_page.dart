import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_moviles/services/objeto_service.dart';

class PublicarObjetoPage extends StatefulWidget {
  const PublicarObjetoPage({super.key});

  @override
  State<PublicarObjetoPage> createState() => _PublicarObjetoPageState();
}

class _PublicarObjetoPageState extends State<PublicarObjetoPage> {
  final _form = GlobalKey<FormState>();
  final _titulo = TextEditingController(),
      _desc = TextEditingController(),
      _lugar = TextEditingController(),
      _fechaTxt = TextEditingController();
  List<String> _cats = [];
  String? _tipo, _cat;
  DateTime? _fecha;
  Uint8List? _foto;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    ObjetoService.categorias().then((c) {
      if (mounted) setState(() => _cats = c);
    });
  }

  @override
  void dispose() {
    for (final c in [_titulo, _desc, _lugar, _fechaTxt]) {
      c.dispose();
    }
    super.dispose();
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  String? _req(String? v, [int min = 1]) => (v == null || v.trim().length < min)
      ? (min == 1 ? 'Campo obligatorio' : 'Mínimo $min caracteres')
      : null;

  Future<void> _elegirFoto() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Cámara'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galería'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    );
    if (origen == null) return;
    final f = await ImagePicker().pickImage(
      source: origen,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (bytes.length > 800 * 1024) {
      _msg('La foto es muy pesada');
      return;
    }
    setState(() => _foto = bytes);
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: DateTime(hoy.year - 1),
      lastDate: hoy,
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t == null || !mounted) return;
    final f = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    if (f.isAfter(hoy)) {
      _msg('La fecha no puede ser futura');
      return;
    }
    setState(() {
      _fecha = f;
      _fechaTxt.text = fmt(f);
    });
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    if (_foto == null) {
      _msg('Agrega una foto (obligatoria)');
      return;
    }
    setState(() => _guardando = true);
    try {
      await ObjetoService.publicar(
        titulo: _titulo.text.trim(),
        descripcion: _desc.text.trim(),
        tipo: _tipo!,
        categoria: _cat!,
        lugar: _lugar.text.trim(),
        fecha: _fecha!,
        foto: _foto!,
        user: FirebaseAuth.instance.currentUser!,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        _msg('No se pudo publicar: $e');
        setState(() => _guardando = false);
      }
    }
  }

  Widget _campo(
    String label,
    TextEditingController c, {
    int min = 1,
    int lineas = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      maxLines: lineas,
      decoration: InputDecoration(labelText: label),
      validator: (v) => _req(v, min),
    ),
  );

  Widget _combo(
    String label,
    String? valor,
    List<String> ops,
    ValueChanged<String?> cambio,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [for (final o in ops) DropdownMenuItem(value: o, child: Text(o))],
      onChanged: cambio,
      validator: (v) => v == null ? 'Selecciona una opción' : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva publicación')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _elegirFoto,
              child: Container(
                height: 180,
                margin: const EdgeInsets.only(bottom: 14),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black26),
                ),
                child: _foto == null
                    ? const Center(
                        child: Text('Toca para agregar la foto (obligatoria)'),
                      )
                    : Image.memory(_foto!, fit: BoxFit.cover),
              ),
            ),
            _campo('Título', _titulo, min: 3),
            _campo('Descripción', _desc, min: 10, lineas: 3),
            _combo('Tipo', _tipo, ['Perdido', 'Encontrado'], (v) => _tipo = v),
            _combo('Categoría', _cat, _cats, (v) => _cat = v),
            _campo('Lugar (ej: Laboratorio U100)', _lugar, min: 3),
            TextFormField(
              controller: _fechaTxt,
              readOnly: true,
              onTap: _elegirFecha,
              decoration: const InputDecoration(
                labelText: 'Fecha y hora (DD/MM/AAAA hh:mm)',
                suffixIcon: Icon(Icons.event),
              ),
              validator: (v) => _req(v),
            ),
            const SizedBox(height: 20),
            _guardando
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: _guardar,
                    child: const Text('Publicar'),
                  ),
          ],
        ),
      ),
    );
  }
}
