import 'package:flutter/material.dart';
import 'dart:math' as math;

class BadgeAnimationWidget extends StatefulWidget {
  final String badgeName;
  final VoidCallback? onAnimationComplete;

  const BadgeAnimationWidget({
    super.key,
    required this.badgeName,
    this.onAnimationComplete,
  });

  @override
  State<BadgeAnimationWidget> createState() => _BadgeAnimationWidgetState();
}

class _BadgeAnimationWidgetState extends State<BadgeAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _sparkleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;

  final List<Sparkle> _sparkles = [];

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.9, curve: Curves.easeInOut),
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    _createSparkles();
    _startAnimation();
  }

  void _createSparkles() {
    final random = math.Random();
    for (int i = 0; i < 16; i++) {
      _sparkles.add(Sparkle(
        position: Offset(
          (random.nextDouble() - 0.5) * 120,
          (random.nextDouble() - 0.5) * 120,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 150,
          (random.nextDouble() - 0.5) * 150,
        ),
        color: _getRandomSparkleColor(),
        size: random.nextDouble() * 8 + 4,
        rotation: random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  Color _getRandomSparkleColor() {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.cyan,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _startAnimation() {
    _controller.forward();
    _sparkleController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _sparkleController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Sparkles
            ..._sparkles.map((sparkle) {
              final progress = _sparkleAnimation.value;
              final position = sparkle.position + sparkle.velocity * progress;
              
              return Positioned(
                left: position.dx + MediaQuery.of(context).size.width / 2,
                top: position.dy + MediaQuery.of(context).size.height / 2,
                child: Transform.rotate(
                  angle: sparkle.rotation + progress * 2 * math.pi,
                  child: Transform.scale(
                    scale: 1 - progress,
                    child: Container(
                      width: sparkle.size,
                      height: sparkle.size,
                      decoration: BoxDecoration(
                        color: sparkle.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: sparkle.color.withValues(alpha: 0.7),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            // Main badge
            Center(
              child: RotationTransition(
                turns: _rotationAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.blue.shade400,
                            Colors.cyan.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'BADGE UNLOCKED!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.badgeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Sparkle {
  final Offset position;
  final Offset velocity;
  final Color color;
  final double size;
  final double rotation;

  Sparkle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotation,
  });
} 