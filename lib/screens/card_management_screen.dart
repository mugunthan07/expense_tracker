import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart';
import '../provider/card_provider.dart';
import 'add_card_screen.dart';

class CardSelectionScreen extends ConsumerWidget {
  final String paymentMethod;

  const CardSelectionScreen({super.key, required this.paymentMethod});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${paymentMethod.toUpperCase()} Card'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _navigateToAddCard(context, ref),
            icon: const Icon(Icons.add),
            tooltip: 'Add Card',
          ),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          debugPrint('❌ CardSelectionScreen error: $error');
          debugPrint('📋 Stack: $stack');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(cardsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (cards) {
          final filtered = cards
              .where((c) => c.cardType == paymentMethod)
              .toList();

          if (filtered.isEmpty) {
            return _EmptyView(
              paymentMethod: paymentMethod,
              onAddCard: () => _navigateToAddCard(context, ref),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _CardItem(
                card: filtered[index],
                onTap: () => Navigator.pop(context, filtered[index]),
              );
            },
          );
        },
      ),
      bottomNavigationBar: cardsAsync.maybeWhen(
        data: (cards) {
          final hasCards = cards.any((c) => c.cardType == paymentMethod);
          if (!hasCards) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => _navigateToAddCard(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add Another Card'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  void _navigateToAddCard(BuildContext context, WidgetRef ref) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddCardScreen()))
        .then((_) => ref.invalidate(cardsProvider));
  }
}

// Card Item Widget
class _CardItem extends StatelessWidget {
  final PaymentCard card;
  final VoidCallback onTap;

  const _CardItem({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Card Type Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _cardColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_cardIcon, color: _cardColor, size: 24),
            ),
            const SizedBox(width: 14),

            // Card Details - Only last 4 digits
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.bankName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '••••  ••••  ••••  ${card.lastFourDigits}',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.grey[600],
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.cardHolderName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            // Default Badge + Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (card.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _cardColor {
    switch (card.cardType) {
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

  IconData get _cardIcon {
    switch (card.cardType) {
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

// Empty State Widget
class _EmptyView extends StatelessWidget {
  final String paymentMethod;
  final VoidCallback onAddCard;

  const _EmptyView({required this.paymentMethod, required this.onAddCard});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${paymentMethod.toUpperCase()} Cards',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a ${paymentMethod.toLowerCase()} card\nto track expenses easily.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAddCard,
              icon: const Icon(Icons.add),
              label: Text('Add ${paymentMethod.toUpperCase()} Card'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

