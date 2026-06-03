import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../router/app_routes.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  void _checkAuthAndNavigate() {
    // Wait for animations to complete, then check auth and navigate
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (mounted) {
        final isAuthenticated = ref.read(isAuthenticatedProvider);
        final isAuthLoading = ref.read(authLoadingProvider);

        // If auth is still loading, stay on splash
        if (isAuthLoading) {
          return;
        }

        // If user is authenticated, go directly to home
        if (isAuthenticated) {
          context.goNamed(AppRoute.home.name);
          return;
        }

        // For non-authenticated users, wait for onboarding state to load
        await _waitForOnboardingToLoad();

        if (mounted) {
          final hasSeenOnboarding = ref.read(hasSeenOnboardingProvider);

          // Navigate based on app state
          if (!hasSeenOnboarding) {
            context.goNamed(AppRoute.onboarding.name);
          } else {
            context.goNamed(AppRoute.login.name);
          }
        }
      }
    });
  }

  /// Wait for onboarding state to finish loading
  Future<void> _waitForOnboardingToLoad() async {
    // Wait up to 3 seconds for onboarding to load
    const maxWaitTime = Duration(seconds: 3);
    const checkInterval = Duration(milliseconds: 100);

    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < maxWaitTime) {
      final isOnboardingLoading = ref.read(onboardingLoadingProvider);

      if (!isOnboardingLoading) {
        // Onboarding has finished loading
        break;
      }

      // Wait a bit before checking again
      await Future.delayed(checkInterval);
    }

    stopwatch.stop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.eco,
                        size: 60.sp,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // App name
                    Text(
                      'Best Farmers',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // App tagline
                    Text(
                      'Connecting You with the Best Farmers',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // Loading indicator
                    SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
