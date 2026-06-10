import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/empty_state_widget.dart';
import '../widgets/permission_denied_widget.dart';

class AppLocalizacao extends StatefulWidget {
  const AppLocalizacao({super.key});

  @override
  State<AppLocalizacao> createState() => _AppLocalizacaoState();
}

class _AppLocalizacaoState extends State<AppLocalizacao> {
  StreamSubscription<Position>? _sub;
  Position? _posicaoAtual;
  bool _carregando = true;
  bool _semPermissao = false;
  bool _servicoDesativado = false;

  @override
  void initState() {
    super.initState();
    _iniciarLocalizacao();
  }

  Future<void> _iniciarLocalizacao() async {
    setState(() {
      _carregando = true;
      _semPermissao = false;
      _servicoDesativado = false;
    });

    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      setState(() {
        _servicoDesativado = true;
        _carregando = false;
      });
      return;
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
      setState(() {
        _semPermissao = true;
        _carregando = false;
      });
      return;
    }

    await _sub?.cancel();
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((posicao) {
      if (!mounted) return;
      setState(() => _posicaoAtual = posicao);
    });

    if (!mounted) return;
    setState(() => _carregando = false);
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
        title: const Text('GPS e geolocalização'),
        actions: [
          IconButton(onPressed: _iniciarLocalizacao, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _servicoDesativado
          ? const EmptyStateWidget(
              icon: Icons.location_disabled,
              title: 'Serviço de localização desativado',
              subtitle: 'Ative o GPS do dispositivo para continuar.',
            )
          : _semPermissao
          ? PermissionDeniedWidget(
              icon: Icons.gps_off,
              title: 'Permissão de localização negada',
              description: 'Este exemplo requer acesso à localização do dispositivo.',
              onRetry: _iniciarLocalizacao,
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.my_location),
                  title: Text(
                    _posicaoAtual == null
                        ? 'Aguardando posição...'
                        : '${_posicaoAtual!.latitude.toStringAsFixed(6)}, ${_posicaoAtual!.longitude.toStringAsFixed(6)}',
                  ),
                  subtitle: _posicaoAtual != null
                      ? Text('Precisão: ${_posicaoAtual!.accuracy.toStringAsFixed(1)} m')
                      : null,
                ),
              ),
            ),
    );
  }
}
