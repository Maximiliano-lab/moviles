import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef Doc = DocumentSnapshot<Map<String, dynamic>>;

String fmt(DateTime f) {
  String d(int n) => n.toString().padLeft(2, '0');
  return '${d(f.day)}/${d(f.month)}/${f.year} ${d(f.hour)}:${d(f.minute)}';
}

class ObjetoService {
  static final _db = FirebaseFirestore.instance;
  static final _col = _db.collection('objetos');
  static const _cats = [
    'Electrónica',
    'Documentos',
    'Ropa y accesorios',
    'Llaves',
    'Útiles',
    'Otros',
  ];

  static Future<List<String>> categorias() async {
    final col = _db.collection('categorias');
    var s = await col.orderBy('orden').get();
    if (s.docs.isEmpty) {
      final b = _db.batch();
      for (var i = 0; i < _cats.length; i++) {
        b.set(col.doc('c$i'), {'nombre': _cats[i], 'orden': i});
      }
      await b.commit();
      s = await col.orderBy('orden').get();
    }
    return s.docs.map((d) => d['nombre'] as String).toList();
  }

  static Stream<List<Doc>> objetos() => _col
      .orderBy('fechaHora', descending: true)
      .snapshots()
      .map((s) => s.docs);

  static Future<void> publicar({
    required String titulo,
    required String descripcion,
    required String tipo,
    required String categoria,
    required String lugar,
    required DateTime fecha,
    required Uint8List foto,
    required User user,
  }) => _col.add({
    'titulo': titulo,
    'descripcion': descripcion,
    'tipo': tipo,
    'categoria': categoria,
    'lugar': lugar,
    'fechaHora': Timestamp.fromDate(fecha),
    'foto': Blob(foto),
    'estado': 'Vigente',
    'autorUid': user.uid,
    'autorNombre': user.displayName ?? '',
    'autorEmail': user.email ?? '',
  });

  static Future<void> devolver(String id) =>
      _col.doc(id).update({'estado': 'Devuelto'});

  static Future<void> borrar(String id) => _col.doc(id).delete();
}
