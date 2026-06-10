import 'dart:io';

import 'package:flutter/material.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final File file;

  const PhotoPreviewScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.file(file, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 48,
            left: 16,
            child: IconButton.filled(
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.close),
            ),
          ),
          Positioned(
            top: 48,
            right: 16,
            child: IconButton.filledTonal(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete),
            ),
          ),
        ],
      ),
    );
  }
}
