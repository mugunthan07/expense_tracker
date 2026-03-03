import 'package:flutter/material.dart' hide NavigationDrawer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mg_expense_tracker/provider/expense_provider.dart';
import 'package:mg_expense_tracker/screens/expense_form_screen.dart';
import 'package:mg_expense_tracker/widgets/expense_filter.dart';
import 'package:mg_expense_tracker/widgets/expense_list.dart';
import 'package:mg_expense_tracker/widgets/monthly_summary.dart';
import '../widgets/navigation_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MG Expense Tracker'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: const NavigationDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ExpenseFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: expenses.when(
        data: (_) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: MonthlySummary(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ExpenseFilter(),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child:
                    ExpenseList(), // Make sure ExpenseList uses ListView internally
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
