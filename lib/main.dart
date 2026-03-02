import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'provider/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state globally
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'MG Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: authState.when(
        // Always show splash screen initially
        loading: () => const SplashScreen(),
        // When data arrives, check if user exists
        data: (user) {
          return _NavigationWrapper(user: user);
        },
        // On error, show login screen
        error: (error, stackTrace) {
          debugPrint('Auth error: $error');
          return const LoginScreen();
        },
      ),
    );
  }
}

// Wrapper to handle navigation with splash screen delay
class _NavigationWrapper extends StatefulWidget {
  final Object? user;
  const _NavigationWrapper({required this.user});

  @override
  State<_NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<_NavigationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    
    // Setup animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animationController.forward();

    // Show splash for 1.8 seconds minimum
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _showSplash = false);
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
    if (_showSplash) {
      return SplashScreen(animationController: _animationController);
    }

    // Show appropriate screen based on user
    return widget.user != null ? const HomeScreen() : const LoginScreen();
  }
}