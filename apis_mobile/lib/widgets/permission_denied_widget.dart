import 'package:flutter/material.dart';

class PermissionDeniedWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onRetry;
  final String retryLabel;

  const PermissionDeniedWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onRetry,
    this.retryLabel = 'Solicitar permissão',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.lock_open),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
