import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseConfig {
  // Firebase Auth instance
  static final FirebaseAuth auth = FirebaseAuth.instance;

  // Firestore instance
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Initialize Firebase configuration
  static void initializeFirebaseRules() {
    // Enable offline persistence (only for mobile platforms)
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Firestore security rules reference (for documentation)
  // Rules should be deployed via Firebase Console or Firebase CLI
  static const String firestoreRulesDoc = '''
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId} {
          allow read, write: if request.auth.uid == userId;
          
          match /expenses/{expenseId} {
            allow read, write: if request.auth.uid == userId;
          }
        }
      }
    }
  ''';
}