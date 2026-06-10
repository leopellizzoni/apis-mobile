import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AppSensores extends StatefulWidget {
  const AppSensores({super.key});

  @override
  State<AppSensores> createState() => _AppSensoresState();
}

class _AppSensoresState extends State<AppSensores> {
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  AccelerometerEvent? _acc;
  GyroscopeEvent? _gyro;
  MagnetometerEvent? _mag;

  @override
  void initState() {
    super.initState();
    _accSub = accelerometerEventStream().listen((e) {
      if (!mounted) return;
      setState(() => _acc = e);
    });
    _gyroSub = gyroscopeEventStream().listen((e) {
      if (!mounted) return;
      setState(() => _gyro = e);
    });
    _magSub = magnetometerEventStream().listen((e) {
      if (!mounted) return;
      setState(() => _mag = e);
    });
  }

  @override
  void dispose() {
    _accSub?.cancel();
    _gyroSub?.cancel();
    _magSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final azimute = _mag == null
        ? null
        : ((math.atan2(_mag!.y, _mag!.x) * 180 / math.pi) + 360) % 360;

    return Scaffold(
      appBar: AppBar(title: const Text('Sensores do dispositivo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SensorCard(
              titulo: 'Acelerômetro (m/s²)',
              icone: Icons.speed,
              valores: _acc == null ? null : [_acc!.x, _acc!.y, _acc!.z],
            ),
            const SizedBox(height: 8),
            _SensorCard(
              titulo: 'Giroscópio (rad/s)',
              icone: Icons.rotate_right,
              valores: _gyro == null ? null : [_gyro!.x, _gyro!.y, _gyro!.z],
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.explore),
                title: const Text('Magnetômetro / bússola'),
                subtitle: Text(
                  azimute == null ? 'Aguardando...' : 'Azimute: ${azimute.toStringAsFixed(1)}°',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final List<double>? valores;

  const _SensorCard({required this.titulo, required this.icone, required this.valores});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icone),
        title: Text(titulo),
        subtitle: valores == null
            ? const Text('Aguardando...')
            : Text(
                'X: ${valores![0].toStringAsFixed(2)}  '
                'Y: ${valores![1].toStringAsFixed(2)}  '
                'Z: ${valores![2].toStringAsFixed(2)}',
              ),
      ),
    );
  }
}
