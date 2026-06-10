import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AppCompartilhamento extends StatefulWidget {
  const AppCompartilhamento({super.key});

  @override
  State<AppCompartilhamento> createState() => _AppCompartilhamentoState();
}

class _AppCompartilhamentoState extends State<AppCompartilhamento> {
  final TextEditingController _controller = TextEditingController(
    text: 'Olá! Compartilhando conteúdo via share sheet nativo.',
  );

  Future<void> _compartilharTexto() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    await Share.share(texto);
  }

  Future<void> _compartilharArquivo() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    final dir = await getTemporaryDirectory();
    final arquivo = File('${dir.path}/share_demo.txt');
    try {
      await arquivo.writeAsString(texto);
    } on FileSystemException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao gerar o arquivo.')),
      );
      return;
    }

    await Share.shareXFiles([XFile(arquivo.path)], text: 'Arquivo gerado no app');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compartilhamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Conteúdo para compartilhar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _compartilharTexto,
              icon: const Icon(Icons.text_fields),
              label: const Text('Compartilhar texto'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _compartilharArquivo,
              icon: const Icon(Icons.attach_file),
              label: const Text('Compartilhar arquivo .txt'),
            ),
          ],
        ),
      ),
    );
  }
}
