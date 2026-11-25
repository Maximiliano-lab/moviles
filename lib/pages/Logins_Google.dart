import 'package:flutter/material.dart';
import 'package:proyecto_moviles/services/Auth_Service.dart';

class LoginsGoogle extends StatefulWidget {
  const LoginsGoogle({super.key});

  @override
  State<LoginsGoogle> createState() => _LoginsGoogleState();
}

class _LoginsGoogleState extends State<LoginsGoogle> {
  bool _cargando = false;

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _entrar() async {
    setState(() => _cargando = true);
    try {
      final c = await GoogleSignInService.singInWithGoogle();
      if (c == null && mounted) _msg('Inicio de sesión cancelado');
    } catch (e) {
      if (mounted) _msg('Error al iniciar sesión con Google');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, cs.tertiary],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.travel_explore, size: 90, color: cs.surface),
                const SizedBox(height: 16),
                const Text(
                  'Objetos perdidos',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Publica lo que perdiste o encontraste en la sede',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),
                _cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : FilledButton.icon(
                        onPressed: _entrar,
                        icon: const Icon(Icons.login),
                        label: const Text('Continuar con Google'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}