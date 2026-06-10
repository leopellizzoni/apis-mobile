import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class AppDeviceInfo extends StatefulWidget {
  const AppDeviceInfo({super.key});

  @override
  State<AppDeviceInfo> createState() => _AppDeviceInfoState();
}

class _AppDeviceInfoState extends State<AppDeviceInfo> {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batterySub;

  Map<String, String> _dadosDispositivo = {};
  int? _nivelBateria;
  BatteryState? _estadoBateria;

  @override
  void initState() {
    super.initState();
    _carregarInfo();
    _batterySub = _battery.onBatteryStateChanged.listen((estado) {
      if (!mounted) return;
      setState(() => _estadoBateria = estado);
    });
  }

  Future<void> _carregarInfo() async {
    final nivel = await _battery.batteryLevel;
    final estado = await _battery.batteryState;

    Map<String, String> info;
    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      info = {
        'Fabricante': android.manufacturer,
        'Modelo': android.model,
        'Android': android.version.release,
        'SDK': '${android.version.sdkInt}',
      };
    } else if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      info = {
        'Modelo': ios.utsname.machine,
        'Sistema': ios.systemName,
        'Versão': ios.systemVersion,
        'Nome': ios.name,
      };
    } else {
      info = {'Plataforma': Platform.operatingSystem};
    }

    if (!mounted) return;
    setState(() {
      _dadosDispositivo = info;
      _nivelBateria = nivel;
      _estadoBateria = estado;
    });
  }

  String _rotuloEstado(BatteryState? estado) {
    switch (estado) {
      case BatteryState.charging:
        return 'Carregando';
      case BatteryState.discharging:
        return 'Descarregando';
      case BatteryState.full:
        return 'Completa';
      case BatteryState.connectedNotCharging:
        return 'Conectado mas não carregando';
      default:
        return 'Desconhecido';
    }
  }

  @override
  void dispose() {
    _batterySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivo & bateria'),
        actions: [
          IconButton(onPressed: _carregarInfo, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.battery_full),
                title: Text('Bateria: ${_nivelBateria ?? '--'}%'),
                subtitle: Text('Estado: ${_rotuloEstado(_estadoBateria)}'),
              ),
            ),
            const SizedBox(height: 8),
            ..._dadosDispositivo.entries.map(
              (entry) => Card(
                child: ListTile(
                  dense: true,
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
