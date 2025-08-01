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

      print('PDF Viewer: Loading document with path: $pdfPath'); // Debug print

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
            print(
              'PDF loaded successfully: ${details.document.pages.count} pages',
            );
            setState(() {
              _isLoading = false;
            });
          },
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            print('PDF load failed: ${details.error}'); // Debug print
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
            print(
              'PDF loaded successfully: ${details.document.pages.count} pages',
            );
            setState(() {
              _isLoading = false;
            });
          },
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            print('PDF load failed: ${details.error}'); // Debug print
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
            print(
              'PDF loaded successfully: ${details.document.pages.count} pages',
            );
            setState(() {
              _isLoading = false;
            });
          },
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            print('PDF load failed: ${details.error}'); // Debug print
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
        title: Text(displayTitle, style: const TextStyle(fontSize: 16)),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.dominantPurple,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading PDF...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.textSecondary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load PDF',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _retryLoading,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dominantPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _pdfViewer,
    );
  }
}
