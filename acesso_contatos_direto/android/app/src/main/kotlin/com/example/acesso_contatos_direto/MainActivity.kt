package com.example.acesso_contatos_direto
import io.flutter.embedding.android.FlutterActivity
import android.Manifest
import android.content.pm.PackageManager
import android.provider.ContactsContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity()
{
    companion object {
        private const val CHANNEL = "com.exemplo.acesso_contatos_direto"
        private const val METHOD_NAME = "obterContatosDaDisciplinaDaUCS"
        private const val REQUEST_READ_CONTACTS = 1001
    }

    private fun lerContatos(): List<Map<String, String>> {
        val contatos = mutableListOf<Map<String, String>>()

        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER
        )

        val cursor = contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            projection, null,  null, ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME + " ASC"
        )

        cursor?.use {
            val nomeIdx = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
            val telefoneIdx = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)

            while (it.moveToNext()) {
                val nome = it.getString(nomeIdx) ?: "Sem nome"
                val telefone = it.getString(telefoneIdx) ?: "Sem telefone"
                contatos.add(mapOf("nome" to nome, "telefone" to telefone))
            }
        }

        return contatos
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_NAME -> {
                    result.success(lerContatos())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}