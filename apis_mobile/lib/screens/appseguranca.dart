import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AppSeguranca extends StatefulWidget {
  const AppSeguranca({super.key});

  @override
  State<AppSeguranca> createState() => _AppSegurancaState();
}

class _AppSegurancaState extends State<AppSeguranca> {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _suportado = false;
  bool _autenticando = false;
  String _status = 'Aguardando ação';
  List<BiometricType> _biometrias = [];

  @override
  void initState() {
    super.initState();
    _verificarSuporteAuth();
  }

  Future<void> _verificarSuporteAuth() async {
    final suportado = await _auth.isDeviceSupported();
    final biometrias = await _auth.getAvailableBiometrics();
    if (!mounted) return;
    setState(() {
      _suportado = suportado;
      _biometrias = biometrias;
    });
  }

  Future<void> _autenticar() async {
    setState(() {
      _autenticando = true;
      _status = 'Solicitando autenticação...';
    });
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Confirme sua identidade',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (!mounted) return;
      setState(() => _status = ok ? 'Autenticado com sucesso ✓' : 'Autenticação cancelada');
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Erro: ${e.message}');
    } finally {
      if (mounted) setState(() => _autenticando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autenticação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  _suportado ? Icons.fingerprint : Icons.warning_amber,
                  color: _suportado ? Colors.green : Colors.orange,
                  size: 32,
                ),
                title: Text(
                  _suportado
                      ? 'Dispositivo suporta autenticação local'
                      : 'Sem suporte a autenticação local',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(
                  spacing: 6,
                  children: _biometrias.isEmpty
                      ? [const Chip(label: Text('Nenhuma biometria disponível'))]
                      : _biometrias.map((b) => Chip(label: Text(b.name))).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_status),
                trailing: _autenticando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: (_suportado && !_autenticando) ? _autenticar : null,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Autenticar'),
            ),
          ],
        ),
      ),
    );
  }
}
