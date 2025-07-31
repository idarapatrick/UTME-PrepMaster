import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class StreakAnimationWidget extends StatefulWidget {
  final int streakCount;
  final VoidCallback? onAnimationComplete;
  final Duration duration;

  const StreakAnimationWidget({
    super.key,
    required this.streakCount,
    this.onAnimationComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<StreakAnimationWidget> createState() => _StreakAnimationWidgetState();
}

class _StreakAnimationWidgetState extends State<StreakAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fireController;
  late AnimationController _scaleController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fireScaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fireController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -120.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fireScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _fireController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Start with scale animation
    await _scaleController.forward();
    
    // Start fire animation
    _fireController.repeat(reverse: true);
    
    // Wait a bit, then start slide and fade
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Start slide and fade animations
    _controller.forward();
    
    // Wait for animation to complete
    await Future.delayed(widget.duration);
    
    if (mounted) {
      widget.onAnimationComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fireController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _fireController, _scaleController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.red,
                      Colors.orange,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: _fireScaleAnimation.value,
                      child: Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.streakCount} Day${widget.streakCount == 1 ? '' : 's'} Streak!',
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