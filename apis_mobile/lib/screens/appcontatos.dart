import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../widgets/empty_state_widget.dart';
import '../widgets/permission_denied_widget.dart';

class AppContatos extends StatefulWidget {
  const AppContatos({super.key});

  @override
  State<AppContatos> createState() => _AppContatosState();
}

class _AppContatosState extends State<AppContatos> {
  List<Contact> _contatos = [];
  bool _carregando = true;
  bool _semPermissao = false;

  @override
  void initState() {
    super.initState();
    _carregarContatos();
  }

  Future<void> _carregarContatos() async {
    setState(() {
      _carregando = true;
      _semPermissao = false;
    });

    final permissao = await FlutterContacts.requestPermission(readonly: false);
    if (!permissao) {
      setState(() {
        _semPermissao = true;
        _carregando = false;
      });
      return;
    }

    final lista = await FlutterContacts.getContacts(withProperties: true);
    lista.sort((a, b) => a.displayName.compareTo(b.displayName));
    setState(() {
      _contatos = lista;
      _carregando = false;
    });
  }

  Future<void> _adicionarContatoDemo() async {
    final contato = Contact()
      ..name.first = 'Aluno'
      ..name.last = 'API Mobile'
      ..phones = [Phone('11999990000')]
      ..emails = [Email('aluno.apimobile@universidade.br')];

    await contato.insert();
    await _carregarContatos();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contato adicionado com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_carregando || _semPermissao ? 'Contatos' : 'Contatos (${_contatos.length})'),
        actions: [
          IconButton(
            onPressed: _carregarContatos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          IconButton(
            onPressed: _adicionarContatoDemo,
            icon: const Icon(Icons.person_add),
            tooltip: 'Adicionar contato demo',
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _semPermissao
          ? PermissionDeniedWidget(
              icon: Icons.contacts,
              title: 'Permissão de contatos negada',
              description: 'Este exemplo requer acesso à lista de contatos.',
              onRetry: _carregarContatos,
              retryLabel: 'Solicitar novamente',
            )
          : _contatos.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.person_search,
              title: 'Nenhum contato encontrado',
            )
          : ListView.separated(
              itemCount: _contatos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final c = _contatos[index];
                final inicial = c.displayName.trim().isNotEmpty
                    ? c.displayName.trim()[0].toUpperCase()
                    : '?';
                return ListTile(
                  leading: CircleAvatar(child: Text(inicial)),
                  title: Text(c.displayName),
                  subtitle: c.phones.isNotEmpty ? Text(c.phones.first.number) : null,
                );
              },
            ),
    );
  }
}
