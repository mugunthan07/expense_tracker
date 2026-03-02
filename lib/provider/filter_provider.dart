import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/expense.dart';
import 'expense_provider.dart';

// Filter state model
class FilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedMonth;
  final String? selectedPaymentType;
  final String? selectedPaymentMethod;

  FilterState({
    this.startDate,
    this.endDate,
    this.selectedMonth,
    this.selectedPaymentType,
    this.selectedPaymentMethod,
  });

  FilterState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? selectedMonth,
    String? selectedPaymentType,
    String? selectedPaymentMethod,
  }) {
    return FilterState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedPaymentType: selectedPaymentType ?? this.selectedPaymentType,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }
}

final filterStateProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());

  void setDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      selectedMonth: null,
    );
  }

  void setMonth(String? month) {
    state = state.copyWith(
      selectedMonth: month,
      startDate: null,
      endDate: null,
    );
  }

  void setPaymentType(String? type) {
    state = state.copyWith(selectedPaymentType: type);
  }

  void setPaymentMethod(String? method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void clearFilters() {
    state = FilterState();
  }
}

// Filtered expenses provider
final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider).maybeWhen(
        data: (data) => data,
        orElse: () => <Expense>[],
      );
  final filter = ref.watch(filterStateProvider);

  return expenses.where((expense) {
    // Filter by date range
    if (filter.startDate != null && expense.date.isBefore(filter.startDate!)) {
      return false;
    }
    if (filter.endDate != null &&
        expense.date.isAfter(filter.endDate!.add(Duration(days: 1)))) {
      return false;
    }

    // Filter by month (YYYY-MM format)
    if (filter.selectedMonth != null) {
      final expenseMonth =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      if (expenseMonth != filter.selectedMonth) {
        return false;
      }
    }

    // Filter by payment type
    if (filter.selectedPaymentType != null &&
        expense.paymentType != filter.selectedPaymentType) {
      return false;
    }

    // Filter by payment method
    if (filter.selectedPaymentMethod != null &&
        expense.paymentMethod != filter.selectedPaymentMethod) {
      return false;
    }

    return true;
  }).toList();
});

// Summary provider
final monthlySummaryProvider = Provider<(double, int)>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);

  double totalAmount = 0;
  for (final expense in expenses) {
    totalAmount += expense.amount;
  }

  return (totalAmount, expenses.length);
});

// Get unique payment types
final paymentTypesProvider = Provider<List<String>>((ref) {
  final expenses = ref.watch(expensesProvider).maybeWhen(
        data: (data) => data,
        orElse: () => <Expense>[],
      );

  final types = <String>{};
  for (final expense in expenses) {
    types.add(expense.paymentType);
  }
  return types.toList();
});

// Get unique payment methods
final paymentMethodsProvider = Provider<List<String>>((ref) {
  final expenses = ref.watch(expensesProvider).maybeWhen(
        data: (data) => data,
        orElse: () => <Expense>[],
      );

  final methods = <String>{};
  for (final expense in expenses) {
    methods.add(expense.paymentMethod);
  }
  return methods.toList();
});

// Get available months
final availableMonthsProvider = Provider<List<String>>((ref) {
  final expenses = ref.watch(expensesProvider).maybeWhen(
        data: (data) => data,
        orElse: () => <Expense>[],
      );

  final months = <String>{};
  for (final expense in expenses) {
    final month =
        '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
    months.add(month);
  }
  return months.toList()..sort((a, b) => b.compareTo(a));
});