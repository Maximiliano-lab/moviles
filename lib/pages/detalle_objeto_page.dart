import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/services/objeto_service.dart';

Widget _fila(IconData i, String t) => ListTile(
  dense: true,
  contentPadding: EdgeInsets.zero,
  leading: Icon(i),
  title: Text(t),
);

class DetalleObjetoPage extends StatelessWidget {
  final Doc doc;
  const DetalleObjetoPage({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final d = doc.data()!;
    final mio = d['autorUid'] == FirebaseAuth.instance.currentUser?.uid;
    final foto = d['foto'] as Blob?;

    Future<void> accion(Future<void> Function() f) async {
      await f();
      if (context.mounted) Navigator.pop(context);
    }

    Future<void> borrar() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('¿Borrar publicación?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Sí'),
            ),
          ],
        ),
      );
      if (ok == true) await accion(() => ObjetoService.borrar(doc.id));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (foto != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(foto.bytes, height: 260, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(d['tipo'])),
              Chip(label: Text(d['categoria'])),
              Chip(label: Text(d['estado'])),
            ],
          ),
          Text(
            d['titulo'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(d['descripcion']),
          const Divider(height: 28),
          _fila(Icons.place, d['lugar']),
          _fila(Icons.schedule, fmt((d['fechaHora'] as Timestamp).toDate())),
          _fila(Icons.person, '${d['autorNombre']} · ${d['autorEmail']}'),
          if (mio) ...[
            const SizedBox(height: 16),
            if (d['estado'] == 'Vigente')
              FilledButton(
                onPressed: () => accion(() => ObjetoService.devolver(doc.id)),
                child: const Text('Marcar como devuelto'),
              ),
            TextButton(
              onPressed: borrar,
              child: const Text('Borrar publicación'),
            ),
          ],
        ],
      ),
    );
  }
}
