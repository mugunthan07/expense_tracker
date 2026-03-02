import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCard {
  final String id;
  final String userId;
  final String cardHolderName;
  final String lastFourDigits; // ✅ Only store last 4 digits
  final String cardType;       // 'credit', 'debit', 'upi'
  final String bankName;
  final bool isDefault;
  final DateTime createdAt;

  PaymentCard({
    required this.id,
    required this.userId,
    required this.cardHolderName,
    required this.lastFourDigits,
    required this.cardType,
    required this.bankName,
    this.isDefault = false,
    required this.createdAt,
  });

  // Display label e.g. "HDFC •••• 4242"
  String get displayLabel => '$bankName ••••  $lastFourDigits';

  // Card type icon label
  String get typeLabel => cardType.toUpperCase();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'cardHolderName': cardHolderName,
      'lastFourDigits': lastFourDigits,
      'cardType': cardType,
      'bankName': bankName,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PaymentCard.fromJson(Map<String, dynamic> json, String docId) {
    return PaymentCard(
      id: docId,
      userId: json['userId'] ?? '',
      cardHolderName: json['cardHolderName'] ?? '',
      lastFourDigits: json['lastFourDigits'] ?? '0000',
      cardType: json['cardType'] ?? 'debit',
      bankName: json['bankName'] ?? '',
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.now())
          : DateTime.now(),
    );
  }

  PaymentCard copyWith({
    String? id,
    String? userId,
    String? cardHolderName,
    String? lastFourDigits,
    String? cardType,
    String? bankName,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardType: cardType ?? this.cardType,
      bankName: bankName ?? this.bankName,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PaymentCard(id: $id, type: $cardType, last4: $lastFourDigits, bank: $bankName)';
  }
}