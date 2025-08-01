import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool showMessage;
  final EdgeInsetsGeometry? padding;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
    this.showMessage = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? AppColors.dominantPurple;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? backgroundColor;
  final bool barrierDismissible;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.backgroundColor,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black54,
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: LoadingWidget(
                    message: loadingMessage ?? 'Loading...',
                    size: 32,
                    showMessage: true,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 48,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.dominantPurple,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 2 : 0,
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor ?? Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loadingText ?? 'Loading...',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foregroundColor ?? Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foregroundColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class LoadingCard extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final Color? cardColor;
  final BorderRadius? borderRadius;

  const LoadingCard({
    super.key,
    this.message,
    this.size = 32.0,
    this.color,
    this.padding,
    this.cardColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor ?? AppColors.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: LoadingWidget(
          message: message,
          size: size,
          color: color,
          showMessage: true,
        ),
      ),
    );
  }
}

class LoadingListTile extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const LoadingListTile({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.dominantPurple,
          ),
        ),
      ),
      title: Text(
        message ?? 'Loading...',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.getTextSecondary(context),
        ),
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final Widget? background;

  const LoadingPage({
    super.key,
    this.message,
    this.size = 48.0,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: background != null
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.getBackgroundPrimary(context),
                    AppColors.getBackgroundSecondary(context),
                  ],
                ),
              ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (background != null) background!,
              const SizedBox(height: 32),
              LoadingWidget(
                message: message,
                size: size,
                color: color,
                showMessage: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 