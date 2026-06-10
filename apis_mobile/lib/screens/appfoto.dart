import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'photo_preview_screen.dart';

class AppFoto extends StatefulWidget {
  const AppFoto({super.key});

  @override
  State<AppFoto> createState() => _AppFotoState();
}

class _AppFotoState extends State<AppFoto> {
  CameraController? _controller;
  bool _carregando = true;
  bool _capturando = false;
  String? _erro;
  final List<File> _fotos = [];

  @override
  void initState() {
    super.initState();
    _iniciarCamera();
  }

  Future<void> _iniciarCamera() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _erro = 'Nenhuma câmera encontrada.');
        return;
      }
      final controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      _controller = controller;
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Erro ao inicializar câmera: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _capturarFoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturando) return;

    setState(() => _capturando = true);
    try {
      final arquivo = await controller.takePicture();
      if (!mounted) return;
      setState(() => _fotos.insert(0, File(arquivo.path)));
    } finally {
      if (mounted) setState(() => _capturando = false);
    }
  }

  Future<void> _abrirPrevia(int index) async {
    final deletar = await showDialog<bool>(
      context: context,
      builder: (_) => PhotoPreviewScreen(file: _fotos[index]),
    );
    if (deletar == true && mounted) {
      setState(() => _fotos.removeAt(index));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Câmera')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
          ? Center(child: Text(_erro!))
          : _controller == null
          ? const Center(child: Text('Nenhuma câmera disponível'))
          : Column(
              children: [
                Expanded(child: CameraPreview(_controller!)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _capturando ? null : _capturarFoto,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_capturando ? 'Capturando...' : 'Capturar'),
                    ),
                  ),
                ),
                if (_fotos.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      itemCount: _fotos.length,
                      itemBuilder: (_, index) {
                        return GestureDetector(
                          onTap: () => _abrirPrevia(index),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                            child: Image.file(_fotos[index], fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
