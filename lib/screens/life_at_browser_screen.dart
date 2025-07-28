import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LifeAtBrowserScreen extends StatefulWidget {
  const LifeAtBrowserScreen({super.key});

  @override
  State<LifeAtBrowserScreen> createState() => _LifeAtBrowserScreenState();
}

class _LifeAtBrowserScreenState extends State<LifeAtBrowserScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  final String lifeAtUrl = "https://lifeat.io/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LifeAt'), backgroundColor: Colors.deepPurple),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(lifeAtUrl)),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (_, __) {
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (_, __) {
              setState(() {
                _isLoading = false;
                _hasError = false;
              });
            },
            onReceivedError: (_, __, ___) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
          if (_hasError)
            const Center(
              child: Text(
                "Failed to load LifeAt. Please check your internet.",
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
