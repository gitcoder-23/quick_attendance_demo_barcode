import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hazirasathi/pages/splash_screen.dart';

import '../components/app_internet_connection_wrapper.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final canCheck = await auth.canCheckBiometrics;
    setState(() {
      _canCheckBiometrics = canCheck;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      print(e);
    }

    if (authenticated) {
      // Authentication success, navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } else {
      // Authentication failed, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppInternetConnectionWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Soujanya FaceX'),
          actions: [
            IconButton(
              icon: const Icon(Icons.fingerprint),
              onPressed: _canCheckBiometrics ? _authenticate : null,
            ),
          ],
        ),
        body: ScreenLock(
          correctString: '58289',
          onUnlocked: () {
            // Handle successful unlock, navigate to home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
            );
          },
          title: const Text('Please enter passcode.'),
          cancelButton: TextButton(
            onPressed: () {
              // Handle cancel button press
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          footer: _canCheckBiometrics
              ? IconButton(
                  icon: const Icon(Icons.fingerprint),
                  onPressed: _authenticate,
                )
              : null,
        ),
      ),
    );
  }
}
