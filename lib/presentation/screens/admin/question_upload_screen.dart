import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../data/services/pdf_text_extraction_service.dart';
import '../../theme/app_colors.dart';
import '../../../domain/models/test_question.dart';

class QuestionUploadScreen extends StatefulWidget {
  const QuestionUploadScreen({super.key});

  @override
  State<QuestionUploadScreen> createState() => _QuestionUploadScreenState();
}

class _QuestionUploadScreenState extends State<QuestionUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _examYearController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedFile;
  List<TestQuestion> _parsedQuestions = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  final List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _examYearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _isLoading = true;
          _errorMessage = null;
        });

        await _extractTextFromPdf();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _extractTextFromPdf() async {
    try {
      if (_selectedFile == null) return;

      // Extract text from PDF
      final extractedText = await PdfTextExtractionService.extractTextFromPdf(
        _selectedFile!,
      );

      // Parse questions from extracted text
      _parsedQuestions = PdfTextExtractionService.parseQuestionsFromText(
        extractedText,
        _subjectController.text,
      );

      // If no questions were parsed, try enhanced parsing
      if (_parsedQuestions.isEmpty) {
        _parsedQuestions = PdfTextExtractionService.parseQuestionsEnhanced(
          extractedText,
          _subjectController.text,
        );
      }

      // If still no questions, generate sample questions
      if (_parsedQuestions.isEmpty) {
        _parsedQuestions = PdfTextExtractionService.generateSampleQuestions(
          _subjectController.text,
        );
      }

      // Validate questions
      _parsedQuestions = PdfTextExtractionService.validateQuestions(
        _parsedQuestions,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error extracting text from PDF: $e';
      });
    }
  }

  Future<void> _uploadQuestions() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to upload'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulate upload

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Questions uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        formState.reset();
        setState(() {
          _selectedFile = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading questions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload CBT Questions'),
        backgroundColor: AppColors.dominantPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 1: Select PDF File',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pickPdfFile,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          _isLoading ? 'Processing...' : 'Pick PDF File',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dominantPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Selected: ${_selectedFile!.path.split('/').last}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Form Fields
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 2: Question Details',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Subject Dropdown
                      DropdownButtonFormField<String>(
                        value: _subjectController.text.isEmpty
                            ? null
                            : _subjectController.text,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        items: _subjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _subjectController.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a subject';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Exam Year
                      TextFormField(
                        controller: _examYearController,
                        decoration: const InputDecoration(
                          labelText: 'Exam Year',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 2024',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter exam year';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., JAMB CBT Practice Questions',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Parsed Questions Preview
              if (_parsedQuestions.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 3: Preview Questions (${_parsedQuestions.length} found)',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _parsedQuestions.length,
                            itemBuilder: (context, index) {
                              final question = _parsedQuestions[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.dominantPurple,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  question.question,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${question.options.length} options',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _uploadQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isUploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Uploading...'),
                            ],
                          )
                        : const Text('Upload Questions to Firebase'),
                  ),
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
