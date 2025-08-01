import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class XpAnimationWidget extends StatefulWidget {
  final int xpEarned;
  final VoidCallback? onAnimationComplete;
  final Duration duration;

  const XpAnimationWidget({
    super.key,
    required this.xpEarned,
    this.onAnimationComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<XpAnimationWidget> createState() => _XpAnimationWidgetState();
}

class _XpAnimationWidgetState extends State<XpAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -100.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startAnimation();
  }

  void _startAnimation() async {
    // Start with scale animation
    await _scaleController.forward();

    // Wait a bit, then start slide and fade
    await Future.delayed(const Duration(milliseconds: 500));

    // Start slide and fade animations
    _controller.forward();
    _fadeController.forward();

    // Wait for animation to complete
    await Future.delayed(widget.duration);

    if (mounted) {
      widget.onAnimationComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _scaleController,
        _fadeController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.dominantPurple,
                      AppColors.dominantPurple.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dominantPurple.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Icon(Icons.star, color: Colors.amber, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.xpEarned} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
