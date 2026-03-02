import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Direct stream from Firebase Auth
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

// Get current user - FIXED to properly extract from stream
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  // Properly extract user from AsyncValue
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

// Sign in provider
final signInProvider = FutureProvider.family<User, (String, String)>(
  (ref, params) async {
    final (email, password) = params;
    final authService = ref.read(authServiceProvider);
    final user = await authService.signIn(email, password);
    return user;
  },
);

// Sign up provider
final signUpProvider = FutureProvider.family<User, (String, String)>(
  (ref, params) async {
    final (email, password) = params;
    final authService = ref.read(authServiceProvider);
    final user = await authService.signUp(email, password);
    return user;
  },
);

// Sign out provider
final signOutProvider = FutureProvider<void>((ref) async {
  final authService = ref.read(authServiceProvider);
  await authService.signOut();
});