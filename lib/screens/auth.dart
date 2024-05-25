import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Executar flutter pub add local_auth no terminal (View -> Terminal)
import 'package:local_auth/local_auth.dart';
import 'package:projeto_apis_flutter/screens/home.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Sem permissão';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Autenticando';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Posicione o dedo no leitor biométrico do seu celular',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Autenticar';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Erro: ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    if (authenticated) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Home()));
    } else {
      setState(() {
        _authorized = 'Não Autorizado';
      });
    }
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Autenticação Biométrica',
            style: TextStyle(
              color: Colors.white, // Define a cor do texto
              fontSize: 20, // Tamanho da fonte
              fontWeight: FontWeight.bold, // Peso da fonte
            ),
          ),
          backgroundColor: const Color.fromRGBO(0, 108, 255, 1.0),
          centerTitle: true, // Alinha o título no centro
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.fingerprint,
                  size: 100,
                  color: Color.fromRGBO(144, 148, 151, 10),
                ),
                const SizedBox(height: 20),
                Text(
                  _authorized,
                  style: const TextStyle(
                      color: Color.fromRGBO(144, 148, 151, 10),
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (_isAuthenticating)
                  ElevatedButton.icon(
                    onPressed: _cancelAuthentication,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Entrar'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(255, 255, 255, 1.0),
                      backgroundColor: const Color.fromRGBO(0, 108, 255, 1.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
