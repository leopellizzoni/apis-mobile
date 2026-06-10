import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContatosScreen extends StatefulWidget {
  const ContatosScreen({super.key});

  @override
  State<ContatosScreen> createState() => _ContatosScreenState();
}

class _ContatosScreenState extends State<ContatosScreen> {
  static const _canal = MethodChannel('com.exemplo.acesso_contatos_direto');

  List<Map<String, String>> _contatos = [];
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _obterContatos();
  }

  Future<void> _obterContatos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resultado = await _canal.invokeMethod<List<dynamic>>(
        'obterContatosDaDisciplinaDaUCS',
      );

      if (resultado != null) {
        setState(() {
          _contatos = resultado
              .map((item) => Map<String, String>.from(item as Map))
              .toList();
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _erro = 'Erro ao obter contatos: ${e.message}\nCódigo: ${e.code}';
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro inesperado: $e';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos (MethodChannel)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregando ? null : _obterContatos,
            tooltip: 'Recarregar contatos',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chamando código nativo via MethodChannel...'),
          ],
        ),
      );
    }

    if (_erro != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            const SizedBox(height: 24),
            const Text(
              'Dica: Certifique-se de conceder permissão de acesso aos contatos '
              'nas configurações do dispositivo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _obterContatos,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_contatos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum contato encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _contatos.length,
            itemBuilder: (context, index) {
              final contato = _contatos[index];
              return ListTile(
                title: Text(contato['nome']!),
                subtitle: Text(contato['telefone']!),
              );
            },
          ),
        ),
      ],
    );
  }
}
