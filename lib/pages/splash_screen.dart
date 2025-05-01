import 'package:flutter/material.dart';
import 'package:hazirasathi/pages/qr_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // Future.delayed(const Duration(seconds: 3), () {
    //   _launchURL();
    // });
    Future.delayed(const Duration(seconds: 3), () {
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (_) => const QrScreen()),
      // );
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const AppWebview(
                  url: 'https://194.164.149.194/web-cam',
                  name: 'Hazira Sathi',
                )),
      );
    });
  }

  // Function to launch the URL in the default browser
  void _launchURL() async {
    final Uri url = Uri.parse('https://www.google.com/'); // Correct URL format
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/images/splash.png'), // Set your image here
            fit: BoxFit.cover, // This will cover the entire screen
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space between elements
          children: [
            // Centered content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 0.6,
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
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
