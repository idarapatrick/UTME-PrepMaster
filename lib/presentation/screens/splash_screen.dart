import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _scaleController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF181A20) : AppColors.backgroundPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Responsive icon container with scale animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.dominantPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context) * 2,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: ResponsiveHelper.getResponsiveIconSize(context, isSmallScreen ? 60 : 80),
                    color: AppColors.dominantPurple,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsivePadding(context) * 1.5),
              
              // Responsive loading indicator with pulse animation
              ScaleTransition(
                scale: _pulseAnimation,
                child: SizedBox(
                  width: ResponsiveHelper.getResponsivePadding(context) * 3,
                  height: ResponsiveHelper.getResponsivePadding(context) * 3,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.dominantPurple),
                    strokeWidth: ResponsiveHelper.getResponsivePadding(context) * 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
