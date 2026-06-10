import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class GalleryPreviewScreen extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;

  const GalleryPreviewScreen({
    super.key,
    required this.assets,
    required this.initialIndex,
  });

  @override
  State<GalleryPreviewScreen> createState() => _GalleryPreviewScreenState();
}

class _GalleryPreviewScreenState extends State<GalleryPreviewScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1}/${widget.assets.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.assets.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (_, index) {
          final asset = widget.assets[index];
          if (asset.type == AssetType.video) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, size: 88, color: Colors.white),
                  SizedBox(height: 12),
                  Text('Visualização de vídeo não suportada', style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          }
          return Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: AssetEntityImage(asset, isOriginal: true, fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
