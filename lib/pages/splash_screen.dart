import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_webview.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _checkPermissions);
  }

  // Add this to your splash screen before navigation
  Future<void> _checkPermissions() async {
    if (await Permission.camera.request().isGranted) {
      // Permissions granted, proceed with navigation
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const AppWebview(
            url: 'https://attendance.billing.soujanya360.com/',
            name: '',
          ),
        ),
      );
    } else {
      // Handle permission denial
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission required'),
          content: Text('Camera permission is needed for attendance check-in'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF000928),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(top: 60),
              child: Image.asset(
                'assets/images/Soujanya.png',
                width: 200,
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 0.8,
                  ),
                ],
              ),
            ),
            // Bottom text
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 45.0, horizontal: 15),
              child: Text(
                'Powered by Dtft Solutions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
