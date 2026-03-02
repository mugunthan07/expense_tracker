import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../provider/expense_provider.dart';
import '../provider/card_provider.dart';
import 'add_card_screen.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final Expense? expense;

  const ExpenseFormScreen({super.key, this.expense});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late String _selectedPaymentType;
  late String _selectedPaymentMethod;
  late String? _selectedCardId;
  bool _isLoading = false;

  final List<String> _paymentTypes = ['Cash', 'Credit Card', 'Debit Card', 'Online Transfer'];
  final List<String> _paymentMethods = ['Visa', 'Mastercard', 'Amex', 'Rupay', 'UPI'];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController = TextEditingController(text: widget.expense!.amount.toString());
      _noteController = TextEditingController(text: widget.expense!.note);
      _selectedDate = widget.expense!.date;
      _selectedPaymentType = widget.expense!.paymentType;
      _selectedPaymentMethod = widget.expense!.paymentMethod;
      _selectedCardId = widget.expense!.cardId;
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedPaymentType = _paymentTypes.first;
      _selectedPaymentMethod = _paymentMethods.first;
      _selectedCardId = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Resolve last 4 digits from selected card
      String resolvedCardLast4 = '';
      if (_selectedCardId != null) {
        final cardList = ref.read(cardsProvider).maybeWhen(
          data: (data) => data,
          orElse: () => [],
        );
        final selectedCard = cardList.where((c) => c.id == _selectedCardId).firstOrNull;
        resolvedCardLast4 = selectedCard?.lastFourDigits ?? '';
      }

      final expense = Expense(
        id: widget.expense?.id ?? '',
        amount: amount,
        date: _selectedDate,
        paymentType: _selectedPaymentType,
        paymentMethod: _selectedPaymentMethod,
        cardId: _selectedCardId,
        cardLast4: resolvedCardLast4,
        note: _noteController.text,
        createdAt: widget.expense?.createdAt ?? DateTime.now(),
      );

      if (widget.expense != null) {
        await ref.read(updateExpenseProvider((widget.expense!.id, expense)).future);
      } else {
        await ref.read(addExpenseProvider(expense).future);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense ${widget.expense != null ? 'updated' : 'added'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Section
            _FormSection(
              title: 'Amount',
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 24),
            // Date Section
            _FormSection(
              title: 'Date',
              child: GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Payment Type Section
            _FormSection(
              title: 'Payment Type',
              child: DropdownButtonFormField<String>(
                initialValue: _selectedPaymentType,
                items: _paymentTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPaymentType = value!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Card Selection Section
            if (_selectedPaymentType != 'Cash')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormSection(
                    title: 'Select Card',
                    child: cards.when(
                      data: (cardList) => cardList.isEmpty
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.blue[600]),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'No cards added yet. Tap below to add a card.',
                                        style: TextStyle(color: Colors.blue[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const AddCardScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Card'),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            children: [
                              DropdownButtonFormField<String?>(
                                initialValue: _selectedCardId,
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: const Text('Select a card...'),
                                  ),
                                  ...cardList.map((card) {
                                    return DropdownMenuItem(
                                      value: card.id,
                                      child: Text(
                                        '${card.cardType} - ****${card.lastFourDigits}',
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) =>
                                    setState(() => _selectedCardId = value),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const AddCardScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add New Card'),
                                ),
                              ),
                            ],
                          ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            // Payment Method Section
            _FormSection(
              title: 'Payment Method',
              child: DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                items: _paymentMethods
                    .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Notes Section
            _FormSection(
              title: 'Notes',
              child: TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Add a note...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 32),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.expense != null ? 'Update Expense' : 'Add Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FormSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}