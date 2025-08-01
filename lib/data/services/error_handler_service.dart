import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'dart:async';

class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  // Error types
  static const String networkError = 'network_error';
  static const String authError = 'auth_error';
  static const String validationError = 'validation_error';
  static const String serverError = 'server_error';
  static const String unknownError = 'unknown_error';
  static const String fileError = 'file_error';
  static const String timeoutError = 'timeout_error';

  // User-friendly error messages
  static const Map<String, String> _errorMessages = {
    networkError: 'No internet connection. Please check your network and try again.',
    authError: 'Authentication failed. Please sign in again.',
    validationError: 'Please check your input and try again.',
    serverError: 'Server error. Please try again later.',
    unknownError: 'Something went wrong. Please try again.',
    fileError: 'File not found or corrupted. Please try again.',
    timeoutError: 'Request timed out. Please check your connection and try again.',
  };

  // Retry configurations
  static const Map<String, int> _retryConfigs = {
    networkError: 3,
    serverError: 2,
    timeoutError: 3,
    unknownError: 1,
  };

  // Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      duration: duration,
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show warning snackbar
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.orange,
      duration: duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show info snackbar
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      duration: duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Handle exceptions and return user-friendly messages
  static String handleException(dynamic exception) {
    if (exception is SocketException) {
      return _errorMessages[networkError]!;
    } else if (exception is HttpException) {
      return _errorMessages[serverError]!;
    } else if (exception is FormatException) {
      return _errorMessages[validationError]!;
    } else if (exception is TimeoutException) {
      return _errorMessages[timeoutError]!;
    } else if (exception is FileSystemException) {
      return _errorMessages[fileError]!;
    } else {
      return _errorMessages[unknownError]!;
    }
  }

  // Get error type from exception
  static String getErrorType(dynamic exception) {
    if (exception is SocketException) {
      return networkError;
    } else if (exception is HttpException) {
      return serverError;
    } else if (exception is FormatException) {
      return validationError;
    } else if (exception is TimeoutException) {
      return timeoutError;
    } else if (exception is FileSystemException) {
      return fileError;
    } else {
      return unknownError;
    }
  }

  // Check if error is retryable
  static bool isRetryable(String errorType) {
    return _retryConfigs.containsKey(errorType);
  }

  // Get retry count for error type
  static int getRetryCount(String errorType) {
    return _retryConfigs[errorType] ?? 0;
  }

  // Check network connectivity
  static Future<bool> isNetworkConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Show loading dialog
  static void showLoadingDialog(
    BuildContext context,
    String message, {
    bool barrierDismissible = false,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (!context.mounted) return;
    
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // Show error dialog
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String buttonText = 'OK',
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  // Execute with retry mechanism
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? errorType,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        final currentErrorType = errorType ?? getErrorType(e);
        
        if (!isRetryable(currentErrorType) || attempts >= maxRetries) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(delay * attempts);
      }
    }
    
    throw Exception('Operation failed after $maxRetries attempts');
  }

  // Handle async operation with loading and error states
  static Future<void> handleAsyncOperation<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String loadingMessage = 'Loading...',
    String? successMessage,
    bool showLoadingDialog = true,
    bool showSuccessMessage = true,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    if (!context.mounted) return;

    try {
      if (showLoadingDialog) {
        ErrorHandlerService.showLoadingDialog(context, loadingMessage);
      }

      await operation();

      if (showLoadingDialog) {
        ErrorHandlerService.hideLoadingDialog(context);
      }

      if (showSuccessMessage && successMessage != null) {
        showSuccessSnackBar(context, successMessage);
      }

      onSuccess?.call();
    } catch (e) {
      if (showLoadingDialog) {
        ErrorHandlerService.hideLoadingDialog(context);
      }

      final errorMessage = handleException(e);
      showErrorSnackBar(context, errorMessage);

      onError?.call();
    }
  }
}

// Custom exception classes
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
} 