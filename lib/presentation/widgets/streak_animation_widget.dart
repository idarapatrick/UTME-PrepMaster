import 'package:flutter/material.dart';
import 'dart:math' as math;

class StreakAnimationWidget extends StatefulWidget {
  final int streakCount;
  final VoidCallback? onAnimationComplete;

  const StreakAnimationWidget({
    super.key,
    required this.streakCount,
    this.onAnimationComplete,
  });

  @override
  State<StreakAnimationWidget> createState() => _StreakAnimationWidgetState();
}

class _StreakAnimationWidgetState extends State<StreakAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fireController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fireAnimation;

  final List<FireParticle> _fireParticles = [];

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _fireController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    _fireAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fireController,
      curve: Curves.easeOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    _createFireParticles();
    _startAnimation();
  }

  void _createFireParticles() {
    final random = math.Random();
    for (int i = 0; i < 12; i++) {
      _fireParticles.add(FireParticle(
        position: Offset(
          (random.nextDouble() - 0.5) * 80,
          (random.nextDouble() - 0.5) * 80,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 100,
          -random.nextDouble() * 150, // Upward movement
        ),
        color: _getRandomFireColor(),
        size: random.nextDouble() * 6 + 3,
      ));
    }
  }

  Color _getRandomFireColor() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.deepOrange,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _startAnimation() {
    _controller.forward();
    _fireController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _fireController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Fire particles
            ..._fireParticles.map((particle) {
              final progress = _fireAnimation.value;
              final position = particle.position + particle.velocity * progress;
              
              return Positioned(
                left: position.dx + MediaQuery.of(context).size.width / 2,
                top: position.dy + MediaQuery.of(context).size.height / 2,
                child: Transform.scale(
                  scale: 1 - progress,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      color: particle.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: particle.color.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            // Main streak text
            Center(
              child: RotationTransition(
                turns: _rotationAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade400,
                            Colors.orange.shade400,
                            Colors.yellow.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 25,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'STREAK!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                '${widget.streakCount} days',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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

class FireParticle {
  final Offset position;
  final Offset velocity;
  final Color color;
  final double size;

  FireParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });
} 