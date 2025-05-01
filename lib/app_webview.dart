import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebview extends StatelessWidget {
  final String? url;
  final String? name;
  const AppWebview({this.url, this.name, super.key});

  @override
  Widget build(BuildContext context) {
    print('url=> $url');
    if (url!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back, color: whiteColor),
          //   onPressed: () => Navigator.of(context).pop(),
          // ),
          title: Text(
            'Error',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Invalid URL'),
        ),
      );
    }

    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.parse(url!));

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(); // Pops the WebView screen from the stack
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            name!,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        body: Builder(builder: (BuildContext context) {
          return WebViewWidget(
            key: key,
            controller: controller,
          );
        }),
      ),
    );
  }
}
