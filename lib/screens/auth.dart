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
        localizedReason: 'Olá, por favor autentique',
        options: const AuthenticationOptions(
          stickyAuth:
              true, //Cenário que solicitou a autenticacao, app saiu de cena e voltou depois: Se true = continua pedindo a autenticação.
          biometricOnly: true, //Remove a opção de usar o PIN
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Autenticando';
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
        appBar: AppBar(
          title: const Text('Auth'),
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 30),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_isAuthenticating)
                  ElevatedButton(
                    onPressed: _cancelAuthentication,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Cancelar'),
                        Icon(Icons.cancel),
                      ],
                    ),
                  )
                else
                  Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _authenticateWithBiometrics,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(_isAuthenticating ? 'Cancela' : 'Entrar'),
                            const Icon(Icons.fingerprint),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
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
