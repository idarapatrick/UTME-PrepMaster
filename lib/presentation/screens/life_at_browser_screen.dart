import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../theme/app_colors.dart';

class LifeAtBrowserScreen extends StatefulWidget {
  const LifeAtBrowserScreen({super.key});

  @override
  State<LifeAtBrowserScreen> createState() => _LifeAtBrowserScreenState();
}

class _LifeAtBrowserScreenState extends State<LifeAtBrowserScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  InAppWebViewController? _webViewController;

  // Use a simpler URL that focuses on the core features
  final String lifeAtUrl = "https://lifeat.io/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'LifeAt Study',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPage,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _hasError ? _buildErrorWidget() : _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(lifeAtUrl)),
      initialSettings: InAppWebViewSettings(
        // Disable media to reduce terminal output
        javaScriptEnabled: true,
        allowsInlineMediaPlayback: false,
        mediaPlaybackRequiresUserGesture: true,
        useShouldOverrideUrlLoading: true,
        useOnLoadResource: false, // Disable resource loading logs
        clearCache: false,
        cacheEnabled: true,
        supportZoom: false,
        displayZoomControls: false,
        builtInZoomControls: false,
        // Disable mixed content to avoid media issues
        mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
        // Disable geolocation
        geolocationEnabled: false,
        // Disable database
        databaseEnabled: false,
        // Disable DOM storage
        domStorageEnabled: false,
        // Disable file access
        allowFileAccess: false,
        allowContentAccess: false,
        // Disable images to reduce loading
        blockNetworkImage: false,
        // Disable JavaScript console
        javaScriptCanOpenWindowsAutomatically: false,
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
      onLoadStop: (controller, url) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      },
      onReceivedError: (controller, request, error) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = 'Failed to load LifeAt. Please check your internet connection.';
        });
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = 'HTTP Error: ${errorResponse.statusCode}';
        });
      },
      onLoadError: (controller, url, code, message) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = 'Load Error: $message';
        });
      },
      // Filter out media content
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url?.toString() ?? '';
        
        // Block video and media URLs
        if (url.contains('.mp4') || 
            url.contains('.webm') || 
            url.contains('.avi') || 
            url.contains('video') ||
            url.contains('media') ||
            url.contains('stream')) {
          return NavigationActionPolicy.CANCEL;
        }
        
        return NavigationActionPolicy.ALLOW;
      },
      // Disable resource loading logs
      onLoadResource: (controller, resource) {
        // Do nothing to reduce terminal output
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load LifeAt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshPage,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dominantPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshPage() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    _webViewController?.reload();
  }
}
