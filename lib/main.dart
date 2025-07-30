import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/pages/main_navigation_page.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  final firebaseResult = await FirebaseConfig.initialize();

  if (firebaseResult.isFailure) {
    // Show error and exit if Firebase initialization fails
    runApp(FirebaseErrorApp(error: firebaseResult.failure!.message));
    return;
  }

  // Run the app
  runApp(const ProviderScope(child: CropsEcommerceApp()));
}

/// Main application widget
class CropsEcommerceApp extends ConsumerWidget {
  const CropsEcommerceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'FreshCrops',
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,

          // Home page
          home: const SplashScreen(),

          // Localization
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('sw', 'TZ'), // Swahili for Tanzania
          ],

          // Builder for global widgets
          builder: (context, child) {
            return MediaQuery(
              // Ensure text scaling doesn't break the UI
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(
                  context,
                ).textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

/// Splash screen widget with authentication check
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
    // Wait for animations to complete, then navigate to main app
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationPage()),
        );
      }
    });
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
                        Icons.agriculture,
                        size: 60.sp,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // App name
                    Text(
                      'FreshCrops',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // App tagline
                    Text(
                      'Fresh Crops, Direct from Farmers',
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

/// Error app for Firebase initialization failures
class FirebaseErrorApp extends StatelessWidget {
  final String error;

  const FirebaseErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Error',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),

                const SizedBox(height: 24),

                const Text(
                  'Firebase Initialization Failed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  error,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    SystemNavigator.pop();
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
