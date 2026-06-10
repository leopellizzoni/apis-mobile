import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../widgets/empty_state_widget.dart';

class _Gravacao {
  final String id;
  final String path;
  final Duration duracao;

  _Gravacao({required this.id, required this.path, required this.duracao});
}

class AppAudio extends StatefulWidget {
  const AppAudio({super.key});

  @override
  State<AppAudio> createState() => _AppAudioState();
}

class _AppAudioState extends State<AppAudio> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  final List<_Gravacao> _gravacoes = [];

  bool _gravando = false;
  String? _arquivoAtual;
  Duration _duracao = Duration.zero;
  Timer? _timer;
  String? _reproduzindoId;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _reproduzindoId = null);
    });
  }

  Future<void> _alternarGravacao() async {
    if (_gravando) {
      await _pararGravacao();
      return;
    }

    final temPermissao = await _recorder.hasPermission();
    if (!temPermissao) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de microfone negada.')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final caminho = '${dir.path}/gravacao_$id.m4a';

    _duracao = Duration.zero;
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: caminho);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _duracao += const Duration(seconds: 1));
    });

    setState(() {
      _gravando = true;
      _arquivoAtual = caminho;
    });
  }

  Future<void> _pararGravacao() async {
    _timer?.cancel();
    _timer = null;
    await _recorder.stop();

    final caminho = _arquivoAtual;
    if (caminho != null) {
      setState(() {
        _gravacoes.insert(
          0,
          _Gravacao(id: DateTime.now().microsecondsSinceEpoch.toString(), path: caminho, duracao: _duracao),
        );
      });
    }

    setState(() {
      _gravando = false;
      _arquivoAtual = null;
    });
  }

  Future<void> _alternarReproducao(_Gravacao gravacao) async {
    if (_reproduzindoId == gravacao.id) {
      await _player.pause();
      setState(() => _reproduzindoId = null);
      return;
    }
    await _player.play(DeviceFileSource(gravacao.path));
    setState(() => _reproduzindoId = gravacao.id);
  }

  Future<void> _removerGravacao(_Gravacao gravacao) async {
    if (_reproduzindoId == gravacao.id) {
      await _player.stop();
      _reproduzindoId = null;
    }
    final arquivo = File(gravacao.path);
    if (await arquivo.exists()) await arquivo.delete();
    setState(() => _gravacoes.removeWhere((e) => e.id == gravacao.id));
  }

  String _formatarDuracao(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Áudio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_gravando)
              Text(
                'REC ${_formatarDuracao(_duracao)}',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: _gravando ? FilledButton.styleFrom(backgroundColor: Colors.red) : null,
              onPressed: _alternarGravacao,
              icon: Icon(_gravando ? Icons.stop : Icons.mic),
              label: Text(_gravando ? 'Parar gravação' : 'Iniciar gravação'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _gravacoes.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.graphic_eq,
                      title: 'Nenhuma gravação ainda',
                      subtitle: 'Grave um áudio para visualizar o histórico.',
                    )
                  : ListView.separated(
                      itemCount: _gravacoes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final g = _gravacoes[index];
                        final reproduzindo = _reproduzindoId == g.id;
                        return ListTile(
                          leading: const Icon(Icons.audio_file),
                          title: Text('Gravação ${_gravacoes.length - index}'),
                          subtitle: Text(_formatarDuracao(g.duracao)),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                onPressed: () => _alternarReproducao(g),
                                icon: Icon(reproduzindo ? Icons.pause : Icons.play_arrow),
                              ),
                              IconButton(
                                onPressed: () => _removerGravacao(g),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
