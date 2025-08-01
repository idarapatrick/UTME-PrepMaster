import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class XpPopupWidget extends StatefulWidget {
  final int xpEarned;
  final String? reason;
  final VoidCallback? onDismiss;
  final Duration duration;

  const XpPopupWidget({
    super.key,
    required this.xpEarned,
    this.reason,
    this.onDismiss,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<XpPopupWidget> createState() => _XpPopupWidgetState();
}

class _XpPopupWidgetState extends State<XpPopupWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _bounceController;

  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -200.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startAnimation();
  }

  void _startAnimation() async {
    // Start fade in
    await _fadeController.forward();
    
    // Start slide in
    await _controller.forward();
    
    // Start scale animation
    await _scaleController.forward();
    
    // Start bounce animation
    _bounceController.repeat(reverse: true);
    
    // Don't auto-dismiss - wait for user to click OK
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  String _getReasonText() {
    switch (widget.reason) {
      case 'quiz_completion':
        return 'Quiz Completed!';
      case 'streak_bonus':
        return 'Streak Bonus!';
      case 'first_quiz':
        return 'First Quiz!';
      case 'perfect_score':
        return 'Perfect Score!';
      case 'cbt_start':
        return 'CBT Started!';
      case 'cbt_completion':
        return 'CBT Completed!';
      case 'study_session':
        return 'Study Session!';
      default:
        return 'XP Earned!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _scaleController,
        _fadeController,
        _bounceController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value * _bounceAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.dominantPurple,
                      AppColors.dominantPurple.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dominantPurple.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // XP Icon with rotation
                    Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Reason text
                    Text(
                      _getReasonText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // XP amount
                    Text(
                      '+${widget.xpEarned} XP',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Progress indicator
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                        value: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // OK Button
                    ElevatedButton(
                      onPressed: () {
                        // Fade out animation
                        _fadeController.reverse().then((_) {
                          if (mounted) {
                            widget.onDismiss?.call();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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