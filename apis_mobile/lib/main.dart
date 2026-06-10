import 'package:flutter/material.dart';

import 'core/app_colors.dart';
import 'screens/appaudio.dart';
import 'screens/appcompartilhamento.dart';
import 'screens/appconectividade.dart';
import 'screens/appcontatos.dart';
import 'screens/appdeviceinfo.dart';
import 'screens/appfoto.dart';
import 'screens/appgaleria.dart';
import 'screens/applocalizacao.dart';
import 'screens/appqrcode.dart';
import 'screens/appseguranca.dart';
import 'screens/appsensores.dart';
import 'screens/appvibracao.dart';

void main() {
  runApp(const AulaApisMoveisApp());
}

class AulaApisMoveisApp extends StatelessWidget {
  const AulaApisMoveisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APIs Mobile',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('APIs Mobile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ApiCard(
            title: 'Câmera',
            icon: Icons.camera_alt,
            color: AppColors.camera,
            builder: () => const AppFoto(),
          ),
          _ApiCard(
            title: 'Galeria',
            icon: Icons.photo_library,
            color: AppColors.gallery,
            builder: () => const AppGaleria(),
          ),
          _ApiCard(
            title: 'Áudio',
            icon: Icons.mic,
            color: AppColors.audio,
            builder: () => const AppAudio(),
          ),
          _ApiCard(
            title: 'Contatos',
            icon: Icons.contacts,
            color: AppColors.contacts,
            builder: () => const AppContatos(),
          ),
          _ApiCard(
            title: 'Autenticação',
            icon: Icons.fingerprint,
            color: AppColors.security,
            builder: () => const AppSeguranca(),
          ),
          _ApiCard(
            title: 'GPS e geolocalização',
            icon: Icons.my_location,
            color: AppColors.location,
            builder: () => const AppLocalizacao(),
          ),
          _ApiCard(
            title: 'Sensores',
            icon: Icons.sensors,
            color: AppColors.sensors,
            builder: () => const AppSensores(),
          ),
          _ApiCard(
            title: 'Conectividade',
            icon: Icons.wifi,
            color: AppColors.connectivity,
            builder: () => const AppConectividade(),
          ),
          _ApiCard(
            title: 'QR Code / Scanner',
            icon: Icons.qr_code_scanner,
            color: AppColors.qrCode,
            builder: () => const AppQrCode(),
          ),
          _ApiCard(
            title: 'Compartilhamento',
            icon: Icons.share,
            color: AppColors.share,
            builder: () => const AppCompartilhamento(),
          ),
          _ApiCard(
            title: 'Dispositivo & bateria',
            icon: Icons.phone_android,
            color: AppColors.deviceInfo,
            builder: () => const AppDeviceInfo(),
          ),
          _ApiCard(
            title: 'Vibração',
            icon: Icons.vibration,
            color: AppColors.vibration,
            builder: () => const AppVibracao(),
          ),
        ],
      ),
    );
  }
}

class _ApiCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget Function() builder;

  const _ApiCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => builder()));
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 48),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
