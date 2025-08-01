import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../theme/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String? pdfPath;
  final String? title;

  const PdfViewerScreen({super.key, this.pdfPath, this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  late Widget _pdfViewer;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      // Hardcoded PDF path
      final pdfPath =
          widget.pdfPath ?? 'assets/pdfs/last_days_at_forcados_high_school.pdf';

      // Validate the PDF path and determine the appropriate viewer
      if (pdfPath.isEmpty) {
        throw Exception('PDF path is empty');
      }

      // Check if it's a network URL
      if (pdfPath.startsWith('http://') || pdfPath.startsWith('https://')) {
        _pdfViewer = SfPdfViewer.network(
          pdfPath,
          canShowPaginationDialog: true,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            setState(() {
              _isLoading = false;
            });
          },
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            setState(() {
              _errorMessage = 'Failed to load PDF: ${details.error}';
              _isLoading = false;
            });
          },
        );
      }
      // Check if it's an asset
      else if (pdfPath.startsWith('assets/')) {
        _pdfViewer = SfPdfViewer.asset(
          pdfPath,
          canShowPaginationDialog: true,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            setState(() {
              _isLoading = false;
            });
          },
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            setState(() {
              _errorMessage = 'Failed to load PDF: ${details.error}';
              _isLoading = false;
            });
          },
        );
      }
      // Treat as local file path
      else {
        final file = File(pdfPath);
        if (!await file.exists()) {
          throw Exception('PDF file does not exist at: $pdfPath');
        }

        _pdfViewer = SfPdfViewer.file(
          file,
          canShowPaginationDialog: true,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            setState(() {
              _isLoading = false;
            });
          },
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            setState(() {
              _errorMessage = 'Failed to load PDF: ${details.error}';
              _isLoading = false;
            });
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadDocument();
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = widget.title ?? 'Last Days at Forcados High School';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayTitle),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryLoading,
              tooltip: 'Retry',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading PDF',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _retryLoading,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _pdfViewer,
    );
  }
}
