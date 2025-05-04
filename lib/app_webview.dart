import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class AppWebview extends StatefulWidget {
  final String url;
  final String name;

  const AppWebview({
    super.key,
    required this.url,
    required this.name,
  });

  @override
  State<AppWebview> createState() => _AppWebviewState();
}

class _AppWebviewState extends State<AppWebview> {
  late InAppWebViewController _webViewController;
  double _progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  bool _showCameraPermissionDialog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          if (await _webViewController.canGoBack()) {
            _webViewController.goBack();
            return false;
          }
          return true;
        },
        child: SafeArea(
          child: Stack(
            children: [
              // WebView content
              _buildWebView(),

              // Loading indicator
              if (_isLoading && !_hasError) _buildProgressIndicator(),

              // Error message
              if (_hasError) _buildErrorWidget(),

              // Camera permission dialog
              if (_showCameraPermissionDialog) _buildCameraPermissionOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        // Enable camera and microphone access
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        // WebRTC settings
        supportZoom: false,
        useShouldOverrideUrlLoading: true,
        preferredContentMode: UserPreferredContentMode.MOBILE,
        // Additional settings for camera access
        cacheEnabled: false,
        transparentBackground: true,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onLoadStart: (controller, url) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      },
      onLoadStop: (controller, url) async {
        setState(() {
          _isLoading = false;
        });
      },
      onProgressChanged: (controller, progress) {
        setState(() {
          _progress = progress / 100;
        });
      },
      onLoadError: (controller, url, code, message) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
      onConsoleMessage: (controller, consoleMessage) {
        // Debugging: Print console messages from the web page
        debugPrint('WebView Console: ${consoleMessage.message}');
      },
      onPermissionRequest: (controller, request) async {
        // Handle camera permission requests
        if (request.resources.contains(Permission.camera)) {
          final status = await Permission.camera.status;
          if (!status.isGranted) {
            setState(() {
              _showCameraPermissionDialog = true;
            });
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.DENY,
            );
          }
        }
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        // Handle specific URLs (like the checkin page)
        final uri = navigationAction.request.url;
        if (uri != null && uri.toString().contains('/web-cam/checkin')) {
          // Ensure camera permissions are granted before proceeding
          final status = await Permission.camera.status;
          if (!status.isGranted) {
            setState(() {
              _showCameraPermissionDialog = true;
            });
            return NavigationActionPolicy.CANCEL;
          }
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(value: _progress),
          const SizedBox(height: 16),
          Text(
            'Loading ${(_progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Failed to load page',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _webViewController.reload();
              setState(() {
                _hasError = false;
                _isLoading = true;
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPermissionOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_enhance, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Camera Access Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'To complete your check-in, we need access to your camera for face recognition.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showCameraPermissionDialog = false;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _showCameraPermissionDialog = false;
                      });
                      await openAppSettings();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
