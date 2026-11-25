import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/pages/detalle_objeto_page.dart';
import 'package:proyecto_moviles/pages/publicar_objeto_page.dart';
import 'package:proyecto_moviles/services/Auth_Service.dart';
import 'package:proyecto_moviles/services/objeto_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _tipo = 'Todos', _cat = 'Todas';
  List<String> _cats = [];
  final _stream = ObjetoService.objetos();

  @override
  void initState() {
    super.initState();
    ObjetoService.categorias()
        .then((c) {
          if (mounted) setState(() => _cats = c);
        })
        .catchError((_) {});
  }

  Widget _combo(
    String label,
    String valor,
    List<String> ops,
    ValueChanged<String?> cambio,
  ) => Expanded(
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: DropdownButtonFormField<String>(
        initialValue: valor,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, isDense: true),
        items: [
          for (final o in ops) DropdownMenuItem(value: o, child: Text(o)),
        ],
        onChanged: cambio,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final nombre = user?.displayName ?? 'Usuario';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hola, ${nombre.split(' ').first}'),
          bottom: TabBar(
            indicatorColor: cs.secondary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Todos'),
              Tab(text: 'Mis publicaciones'),
            ],
          ),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: cs.primary),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: user?.photoURL == null
                      ? null
                      : NetworkImage(user!.photoURL!),
                ),
                accountName: Text(nombre),
                accountEmail: Text(user?.email ?? ''),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () => GoogleSignInService.signOut(),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PublicarObjetoPage()),
          ),
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Publicar'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                _combo('Tipo', _tipo, [
                  'Todos',
                  'Perdido',
                  'Encontrado',
                ], (v) => setState(() => _tipo = v!)),
                _combo('Categoría', _cat, [
                  'Todas',
                  ..._cats,
                ], (v) => setState(() => _cat = v!)),
              ],
            ),
            Expanded(
              child: StreamBuilder<List<Doc>>(
                stream: _stream,
                builder: (context, snap) {
                  if (snap.hasError)
                    return Center(child: Text('${snap.error}'));
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data!
                      .where(
                        (d) =>
                            (_tipo == 'Todos' || d['tipo'] == _tipo) &&
                            (_cat == 'Todas' || d['categoria'] == _cat),
                      )
                      .toList();
                  final mios = docs
                      .where((d) => d['autorUid'] == user?.uid)
                      .toList();
                  return TabBarView(children: [_Lista(docs), _Lista(mios)]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  final List<Doc> docs;
  const _Lista(this.docs);

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) return const Center(child: Text('No hay publicaciones'));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
      itemCount: docs.length,
      itemBuilder: (_, i) {
        final d = docs[i];
        final foto = d['foto'] as Blob?;
        final color = d['tipo'] == 'Perdido'
            ? Colors.red.shade300
            : Colors.green.shade400;

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color, width: 1.5),
          ),
          child: ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetalleObjetoPage(doc: d)),
            ),
            leading: foto == null
                ? const Icon(Icons.image)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      foto.bytes,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
            title: Text(d['titulo']),
            subtitle: Text(
              '${d['tipo']} · ${d['categoria']}\n'
              '${d['lugar']} · ${fmt((d['fechaHora'] as Timestamp).toDate())}',
            ),
            isThreeLine: true,
            trailing: d['estado'] == 'Devuelto'
                ? const Chip(label: Text('Devuelto'))
                : null,
          ),
        );
      },
    );
  }
}
