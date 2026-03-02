import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart';
import '../services/card_service.dart';
import 'auth_provider.dart';

final cardServiceProvider = Provider<CardService>((ref) => CardService());

// ✅ FIX: Get userId directly from FirebaseAuth
// Don't depend on authStateProvider chain which causes loading delay
final userIdProvider = Provider<String?>((ref) {
  // Primary: watch auth state changes
  final authState = ref.watch(authStateProvider);

  final uid = authState.maybeWhen(
    data: (user) => user?.uid,
    orElse: () => null,
  );

  // ✅ Fallback: directly from FirebaseAuth instance
  // This prevents null during brief loading state
  final resolvedUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
  return resolvedUid;
});

// ✅ FIXED cardsProvider
final cardsProvider = StreamProvider<List<PaymentCard>>((ref) {
  final userId = ref.watch(userIdProvider);


  // ✅ If no userId, return empty immediately (don't stay loading)
  if (userId == null || userId.isEmpty) {
    return Stream.value(<PaymentCard>[]);
  }

  final cardService = ref.read(cardServiceProvider);
  return cardService.getCards(userId);
});

final addCardProvider = FutureProvider.family<void, PaymentCard>(
  (ref, card) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) throw Exception('Not authenticated');

    await ref.read(cardServiceProvider).addCard(userId, card);
    ref.invalidate(cardsProvider);
  },
);

final deleteCardProvider = FutureProvider.family<void, String>(
  (ref, cardId) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) throw Exception('Not authenticated');

    await ref.read(cardServiceProvider).deleteCard(userId, cardId);
    ref.invalidate(cardsProvider);
  },
);

final setDefaultCardProvider = FutureProvider.family<void, String>(
  (ref, cardId) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) throw Exception('Not authenticated');

    await ref.read(cardServiceProvider).setDefaultCard(userId, cardId);
    ref.invalidate(cardsProvider);
  },
);