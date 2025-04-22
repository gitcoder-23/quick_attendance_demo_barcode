import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audioplayers/audioplayers.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final player = AudioPlayer();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    // Ensure the screen stays awake when the app is launched
    WakelockPlus.enable();
    Future.delayed(const Duration(seconds: 2), () {
      controller?.resumeCamera();
    });
  }

  @override
  void dispose() {
    // Disable wakelock when the widget is disposed to prevent memory leaks
    WakelockPlus.disable();
    super.dispose();
  }

  // Function to send the QR code to the API
  onQrSend(String qrCode) async {
    log('qrCode=> $qrCode');
    final apiUrl = "https://school.dtftsolutions.com/api/capture-attendance";

    // Initialize the audio player
    final audioPlayer = AudioPlayer();

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['data'] = qrCode.toString(); // or qrCode.toString()

      var response =
          await request.send(); // Sends the request as multipart/form-data

      if (response.statusCode == 200) {
        // Successfully sent the data
        var responseData = await response.stream.bytesToString();
        log('Response: $responseData');
        var jsonResponse = jsonDecode(responseData);

        log('Response status: ${jsonResponse['status']}');
        log('Response message: ${jsonResponse['response']}');

        // Check if attendance was successfully marked
        if (jsonResponse['status'] == true) {
          await controller?.pauseCamera();
          // Play success sound
          try {
            await audioPlayer
                .play(AssetSource('assets/sounds/success_sound2.mp3'));
          } catch (e) {
            log('Error playing success sound: $e');
          }

          // Show a dialog confirming attendance
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Attendance Accepted"),
                content: const Text("Attendance has been marked successfully."),
              );
            },
          );

          // Close the dialog after 3 seconds
          Future.delayed(const Duration(seconds: 2), () async {
            Navigator.of(context).pop();
            await controller?.resumeCamera();
          });
        } else {
          await controller?.pauseCamera();

          // Play failure sound (optional)
          try {
            await audioPlayer.play(AssetSource('assets/sounds/fail_sound.mp3'));
          } catch (e) {
            log('Error playing fail sound: $e');
          }

          // Show a dialog for attendance rejection
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Attendance Rejected"),
                content: const Text(""),
              );
            },
          );

          Future.delayed(const Duration(seconds: 2), () async {
            Navigator.of(context).pop();
            await controller?.resumeCamera();
          });
        }
      } else {
        log('Failed to send data. Status: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Column(
        children: <Widget>[
          Expanded(flex: 3, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // if (result != null)
                  //   Text('Barcode Data: ${result!.code}')
                  // else
                  //   const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 8, right: 8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Text(
                                  'Flash ${snapshot.data == false ? 'Off' : 'On'}');
                            },
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Text(
                                    'Camera facing ${describeEnum(snapshot.data!)}');
                              } else {
                                return const Text('loading');
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     Container(
                  //       margin: const EdgeInsets.all(8),
                  //       child: ElevatedButton(
                  //         onPressed: () async {
                  //           await controller?.pauseCamera();
                  //         },
                  //         child: const Text('Pause',
                  //             style: TextStyle(fontSize: 15)),
                  //       ),
                  //     ),
                  //     Container(
                  //       margin: const EdgeInsets.all(8),
                  //       child: ElevatedButton(
                  //         onPressed: () async {
                  //           await controller?.resumeCamera();
                  //         },
                  //         child: const Text('Resume',
                  //             style: TextStyle(fontSize: 15)),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      print('result=> $result');

      // After getting the result, send it after 1 seconds delay
      if (result != null) {
        Future.delayed(const Duration(seconds: 1), () {
          onQrSend(result!.code.toString());
        });
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No permission')),
      );
    }
  }
}
