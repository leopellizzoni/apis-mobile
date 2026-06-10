package com.example.apis_mobile_ucs

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity é obrigatório para o plugin local_auth.
// BiometricPrompt.authenticate() exige um FragmentManager para gerenciar
// o ciclo de vida do diálogo biométrico do sistema.
// FlutterActivity (padrão) estende AppCompatActivity sem suporte a Fragment,
// o que causaria crash ao exibir o BiometricPrompt.
class MainActivity : FlutterFragmentActivity()
