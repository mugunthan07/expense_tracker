import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card.dart';

class CardService {
  static final CardService _instance = CardService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CardService._internal();
  factory CardService() => _instance;

  Stream<List<PaymentCard>> getCards(String userId) {

    // ✅ CRITICAL FIX: Removed orderBy('createdAt')
    // orderBy + where needs composite Firestore index
    // Without index → stream never emits → stuck on loading
    return _firestore
        .collection('cards')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {

          final cards = snapshot.docs.map((doc) {
            return PaymentCard.fromJson(doc.data(), doc.id);
          }).toList();

          // ✅ Sort in memory instead of Firestore orderBy
          cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return cards;
        });
  }

  Future<String> addCard(String userId, PaymentCard card) async {
    try {
      final data = card.copyWith(userId: userId).toJson();

      final docRef = await _firestore.collection('cards').add(data);
      return docRef.id;
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> deleteCard(String userId, String cardId) async {
    try {
      await _firestore.collection('cards').doc(cardId).delete();
    } on FirebaseException {
      rethrow;
    }
  }

  Future<PaymentCard?> getDefaultCard(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return PaymentCard.fromJson(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } on FirebaseException {
      return null;
    }
  }

  Future<void> setDefaultCard(String userId, String cardId) async {
    try {
      final batch = _firestore.batch();

      // Remove existing defaults
      final existing = await _firestore
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .get();

      for (var doc in existing.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set new default
      batch.update(
        _firestore.collection('cards').doc(cardId),
        {'isDefault': true},
      );

      await batch.commit();
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> updateCard(String userId, PaymentCard card) async {
    try {
      await _firestore.collection('cards').doc(card.id).update({
        'cardHolderName': card.cardHolderName,
        'cardType': card.cardType,
        'bankName': card.bankName,
        'isDefault': card.isDefault,
      });
    } on FirebaseException {
      rethrow;
    }
  }
}