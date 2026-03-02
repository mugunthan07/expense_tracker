import '../models/expense.dart';
import 'firebase_service.dart';

class ExpenseService {
  static final ExpenseService _instance = ExpenseService._internal();

  ExpenseService._internal();

  factory ExpenseService() {
    return _instance;
  }

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> addExpense(String uid, Expense expense) async {
    await _firebaseService.getUserExpensesCollection(uid).add(expense.toFirestore());
  }

  Future<void> updateExpense(String uid, String expenseId, Expense expense) async {
    await _firebaseService
        .getUserExpensesCollection(uid)
        .doc(expenseId)
        .update(expense.toFirestore());
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _firebaseService.getUserExpensesCollection(uid).doc(expenseId).delete();
  }

  Stream<List<Expense>> getExpenses(String uid) {
    return _firebaseService
        .getUserExpensesCollection(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }
}