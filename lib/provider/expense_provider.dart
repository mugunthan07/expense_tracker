import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'auth_provider.dart';

final expenseServiceProvider = Provider((ref) => ExpenseService());

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final expenseService = ref.watch(expenseServiceProvider);

  if (currentUser == null) {
    return Stream.value([]);
  }

  return expenseService.getExpenses(currentUser.uid);
});

final addExpenseProvider = FutureProvider.family<void, Expense>((ref, expense) async {
  final currentUser = ref.read(currentUserProvider);
  final expenseService = ref.read(expenseServiceProvider);

  if (currentUser != null) {
    await expenseService.addExpense(currentUser.uid, expense);
  }
});

final updateExpenseProvider = FutureProvider.family<void, (String, Expense)>((ref, params) async {
  final currentUser = ref.read(currentUserProvider);
  final expenseService = ref.read(expenseServiceProvider);
  final (expenseId, expense) = params;

  if (currentUser != null) {
    await expenseService.updateExpense(currentUser.uid, expenseId, expense);
  }
});

final deleteExpenseProvider = FutureProvider.family<void, String>((ref, expenseId) async {
  final currentUser = ref.read(currentUserProvider);
  final expenseService = ref.read(expenseServiceProvider);

  if (currentUser != null) {
    await expenseService.deleteExpense(currentUser.uid, expenseId);
  }
});