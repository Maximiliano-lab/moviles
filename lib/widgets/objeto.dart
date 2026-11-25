import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

String formatearFechaHora(DateTime f) {
  String d2(int n) => n.toString().padLeft(2, '0');
  return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
}

class Objeto {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String categoriaId;
  final String categoriaNombre;
  final String lugar;
  final DateTime fechaHora;
  final Uint8List? foto;
  final String estado;
  final String autorUid;
  final String autorNombre;
  final String autorEmail;

  const Objeto({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.categoriaId,
    required this.categoriaNombre,
    required this.lugar,
    required this.fechaHora,
    required this.foto,
    required this.estado,
    required this.autorUid,
    required this.autorNombre,
    required this.autorEmail,
  });

  bool get vigente => estado == 'Vigente';
  bool get esPerdido => tipo == 'Perdido';

  factory Objeto.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final blob = d['foto'];
    return Objeto(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      descripcion: d['descripcion'] ?? '',
      tipo: d['tipo'] ?? 'Perdido',
      categoriaId: d['categoriaId'] ?? '',
      categoriaNombre: d['categoriaNombre'] ?? '',
      lugar: d['lugar'] ?? '',
      fechaHora: (d['fechaHora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      foto: blob is Blob ? blob.bytes : null,
      estado: d['estado'] ?? 'Vigente',
      autorUid: d['autorUid'] ?? '',
      autorNombre: d['autorNombre'] ?? '',
      autorEmail: d['autorEmail'] ?? '',
    );
  }
}
