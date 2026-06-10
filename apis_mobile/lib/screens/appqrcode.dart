import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/empty_state_widget.dart';
import '../widgets/section_header.dart';

class AppQrCode extends StatefulWidget {
  const AppQrCode({super.key});

  @override
  State<AppQrCode> createState() => _AppQrCodeState();
}

class _AppQrCodeState extends State<AppQrCode> {
  final MobileScannerController _controller = MobileScannerController();
  final List<String> _historico = [];
  DateTime? _ultimaLeitura;

  void _aoDetectar(BarcodeCapture captura) {
    final codigo = captura.barcodes.isNotEmpty ? captura.barcodes.first.rawValue?.trim() : null;
    if (codigo == null || codigo.isEmpty) return;

    final agora = DateTime.now();
    if (_ultimaLeitura != null && agora.difference(_ultimaLeitura!) < const Duration(milliseconds: 350)) {
      return;
    }
    _ultimaLeitura = agora;

    if (!_historico.contains(codigo)) {
      setState(() => _historico.insert(0, codigo));
    }
  }

  Future<void> _abrirUrl(String valor) async {
    final uri = Uri.tryParse(valor);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O código lido não é uma URL válida.')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code / Scanner')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              clipBehavior: Clip.antiAlias,
              child: MobileScanner(controller: _controller, onDetect: _aoDetectar),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SectionHeader(title: 'Histórico de códigos lidos'),
          ),
          Expanded(
            child: _historico.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.qr_code,
                    title: 'Nenhum QR Code lido',
                    subtitle: 'Aponte a câmera para iniciar a leitura.',
                  )
                : ListView.separated(
                    itemCount: _historico.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final valor = _historico[index];
                      return ListTile(
                        leading: const Icon(Icons.qr_code_2),
                        title: Text(valor),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _abrirUrl(valor),
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
