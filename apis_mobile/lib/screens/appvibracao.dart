import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class AppVibracao extends StatefulWidget {
  const AppVibracao({super.key});

  @override
  State<AppVibracao> createState() => _AppVibracaoState();
}

class _AppVibracaoState extends State<AppVibracao> {
  bool _hasVibrator = false;
  bool _hasAmplitudeControl = false;
  final TextEditingController _patternController = TextEditingController(text: '0,150,80,250');

  @override
  void initState() {
    super.initState();
    _verificarCapacidades();
  }

  Future<void> _verificarCapacidades() async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    final hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;
    if (!mounted) return;
    setState(() {
      _hasVibrator = hasVibrator;
      _hasAmplitudeControl = hasAmplitudeControl;
    });
  }

  List<int> _parsePattern() {
    return _patternController.text
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .where((e) => e >= 0)
        .toList();
  }

  Future<void> _vibrarPadrao() async {
    final pattern = _parsePattern();
    if (pattern.length < 2) return;
    await Vibration.vibrate(pattern: pattern);
  }

  @override
  void dispose() {
    _patternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vibração / Haptic')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_input_component),
                title: Text('Vibrador: ${_hasVibrator ? 'Disponível' : 'Indisponível'}'),
                subtitle: Text('Controle de amplitude: ${_hasAmplitudeControl ? 'Sim' : 'Não'}'),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => HapticFeedback.lightImpact(),
                  child: const Text('Haptic leve'),
                ),
                FilledButton.tonal(
                  onPressed: () => HapticFeedback.heavyImpact(),
                  child: const Text('Haptic forte'),
                ),
                OutlinedButton(
                  onPressed: () => HapticFeedback.selectionClick(),
                  child: const Text('Seleção'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _patternController,
              decoration: const InputDecoration(
                labelText: 'Padrão (ms) ex: 0,150,80,250',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _hasVibrator ? _vibrarPadrao : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Executar padrão'),
                ),
                OutlinedButton.icon(
                  onPressed: Vibration.cancel,
                  icon: const Icon(Icons.stop),
                  label: const Text('Parar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
