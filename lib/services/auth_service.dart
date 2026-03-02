import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  // Get real-time auth state changes - returns custom User model
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return User.fromFirebaseUser(firebaseUser);
    });
  }

  // Get current user immediately
  User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return User.fromFirebaseUser(firebaseUser);
  }

  // Sign in
  Future<User> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (userCredential.user == null) {
        throw Exception('Sign in failed');
      }
      return User.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up
  Future<User> signUp(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (userCredential.user == null) {
        throw Exception('Sign up failed');
      }
      return User.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Error signing out: ${e.toString()}');
    }
  }

  // Handle Firebase exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'user-not-found';
      case 'wrong-password':
        return 'wrong-password';
      case 'invalid-email':
        return 'invalid-email';
      case 'user-disabled':
        return 'user-disabled';
      case 'too-many-requests':
        return 'too-many-requests';
      case 'email-already-in-use':
        return 'email-already-in-use';
      case 'operation-not-allowed':
        return 'operation-not-allowed';
      case 'weak-password':
        return 'weak-password';
      case 'network-request-failed':
        return 'network-request-failed';
      case 'invalid-credential':
        return 'invalid-credential';
      default:
        return e.code;
    }
  }
}