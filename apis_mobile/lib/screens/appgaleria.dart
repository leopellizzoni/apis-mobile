import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../widgets/empty_state_widget.dart';
import '../widgets/permission_denied_widget.dart';
import 'gallery_preview_screen.dart';

class AppGaleria extends StatefulWidget {
  const AppGaleria({super.key});

  @override
  State<AppGaleria> createState() => _AppGaleriaState();
}

class _AppGaleriaState extends State<AppGaleria> {
  final List<AssetEntity> _assets = [];
  bool _carregando = true;
  bool _semPermissao = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _semPermissao = false;
    });

    final permissao = await PhotoManager.requestPermissionExtend();
    if (!permissao.isAuth) {
      setState(() {
        _semPermissao = true;
        _carregando = false;
      });
      return;
    }

    final albuns = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (albuns.isNotEmpty) {
      final fotos = await albuns.first.getAssetListPaged(page: 0, size: 500);
      _assets
        ..clear()
        ..addAll(fotos);
    }

    if (!mounted) return;
    setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeria')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _semPermissao
          ? PermissionDeniedWidget(
              icon: Icons.photo_library,
              title: 'Permissão de galeria negada',
              description: 'Este exemplo requer acesso à galeria do dispositivo.',
              onRetry: _carregar,
            )
          : _assets.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.photo_library_outlined,
              title: 'Nenhuma imagem encontrada',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _assets.length,
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GalleryPreviewScreen(assets: _assets, initialIndex: index),
                    ),
                  ),
                  child: AssetEntityImage(_assets[index], isOriginal: false, fit: BoxFit.cover),
                );
              },
            ),
    );
  }
}
