import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class AppConectividade extends StatefulWidget {
  const AppConectividade({super.key});

  @override
  State<AppConectividade> createState() => _AppConectividadeState();
}

class _AppConectividadeState extends State<AppConectividade> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  List<ConnectivityResult> _estado = const [];

  @override
  void initState() {
    super.initState();
    _verificarEstado();
    _sub = _connectivity.onConnectivityChanged.listen((resultado) {
      if (!mounted) return;
      setState(() => _estado = resultado);
    });
  }

  Future<void> _verificarEstado() async {
    final resultado = await _connectivity.checkConnectivity();
    if (!mounted) return;
    setState(() => _estado = resultado);
  }

  String _rotulo(ConnectivityResult resultado) {
    switch (resultado) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Dados móveis';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return 'Sem conexão';
      default:
        return 'Outra';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectividade'),
        actions: [
          IconButton(onPressed: _verificarEstado, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            leading: const Icon(Icons.network_check),
            title: const Text('Estado atual da rede'),
            subtitle: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _estado.isEmpty
                  ? [const Chip(label: Text('Sem dados'))]
                  : _estado.map((e) => Chip(label: Text(_rotulo(e)))).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
