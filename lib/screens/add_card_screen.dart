import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart';
import '../provider/card_provider.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _lastFourController = TextEditingController();
  final _bankNameController = TextEditingController();
  String _selectedCardType = 'debit';
  bool _isLoading = false;
  bool _isDefault = false;

  final List<String> _cardTypes = ['credit', 'debit', 'upi'];

  @override
  void dispose() {
    _cardHolderController.dispose();
    _lastFourController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(userIdProvider);
    if (userId == null) {
      _showSnackbar('User not authenticated', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final card = PaymentCard(
        id: '',
        userId: userId,
        cardHolderName: _cardHolderController.text.trim(),
        lastFourDigits: _lastFourController.text.trim(),
        cardType: _selectedCardType,
        bankName: _bankNameController.text.trim(),
        isDefault: _isDefault,
        createdAt: DateTime.now(),
      );

      await ref.read(addCardProvider(card).future);

      if (mounted) {
        _showSnackbar('Card added successfully ✅');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Failed to add card: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Preview
              _CardPreview(
                lastFour: _lastFourController.text,
                cardHolder: _cardHolderController.text,
                bankName: _bankNameController.text,
                cardType: _selectedCardType,
              ),
              const SizedBox(height: 28),

              // Cardholder Name
              _buildLabel('Cardholder Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cardHolderController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('e.g. John Doe', Icons.person),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  if (v.trim().length < 3) return 'Min 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Last 4 Digits
              _buildLabel('Last 4 Digits'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastFourController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                onChanged: (_) => setState(() {}),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('e.g. 4242', Icons.credit_card)
                    .copyWith(counterText: ''),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Last 4 digits required';
                  if (v.length != 4) return 'Must be exactly 4 digits';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bank Name
              _buildLabel('Bank Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bankNameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('e.g. HDFC Bank', Icons.account_balance),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Bank name is required';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Card Type
              _buildLabel('Card Type'),
              const SizedBox(height: 8),
              Row(
                children: _cardTypes.map((type) {
                  final isSelected = _selectedCardType == type;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCardType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _cardTypeColor(type)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? _cardTypeColor(type)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _cardTypeIcon(type),
                                color: isSelected ? Colors.white : Colors.grey,
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Set as Default
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as Default Card'),
                subtitle: Text(
                  'Use this card by default when adding expenses',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              const SizedBox(height: 28),

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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Add Card',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Color _cardTypeColor(String type) {
    switch (type) {
      case 'credit':
        return Colors.blue;
      case 'debit':
        return Colors.purple;
      case 'upi':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _cardTypeIcon(String type) {
    switch (type) {
      case 'credit':
        return Icons.credit_card;
      case 'debit':
        return Icons.payment;
      case 'upi':
        return Icons.phonelink_lock;
      default:
        return Icons.credit_card;
    }
  }
}

// Card Preview Widget
class _CardPreview extends StatelessWidget {
  final String lastFour;
  final String cardHolder;
  final String bankName;
  final String cardType;

  const _CardPreview({
    required this.lastFour,
    required this.cardHolder,
    required this.bankName,
    required this.cardType,
  });

  Color get _cardColor {
    switch (cardType) {
      case 'credit':
        return Colors.blue.shade700;
      case 'debit':
        return Colors.purple.shade700;
      case 'upi':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_cardColor, _cardColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _cardColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bankName.isEmpty ? 'Bank Name' : bankName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                cardType.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Text(
            '••••  ••••  ••••  ${lastFour.isEmpty ? '****' : lastFour}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Courier',
              letterSpacing: 2,
            ),
          ),
          Text(
            cardHolder.isEmpty ? 'CARD HOLDER' : cardHolder.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}