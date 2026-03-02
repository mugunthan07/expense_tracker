import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final double amount;
  final DateTime date;
  final String paymentType;
  final String paymentMethod;
  final String? cardId;
  final String cardLast4;
  final String note;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.date,
    required this.paymentType,
    required this.paymentMethod,
    this.cardId,
    required this.cardLast4,
    required this.note,
    required this.createdAt,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      paymentType: data['paymentType'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      cardId: data['cardId'],
      cardLast4: data['cardLast4'] ?? '',
      note: data['note'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'paymentType': paymentType,
      'paymentMethod': paymentMethod,
      'cardId': cardId,
      'cardLast4': cardLast4,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Expense copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? paymentType,
    String? paymentMethod,
    String? cardId,
    String? cardLast4,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentType: paymentType ?? this.paymentType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardId: cardId ?? this.cardId,
      cardLast4: cardLast4 ?? this.cardLast4,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}