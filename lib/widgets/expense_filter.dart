import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/filter_provider.dart';

class ExpenseFilter extends ConsumerStatefulWidget {
  const ExpenseFilter({super.key});

  @override
  ConsumerState<ExpenseFilter> createState() => _ExpenseFilterState();
}

class _ExpenseFilterState extends ConsumerState<ExpenseFilter> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(filterStateProvider);
    final paymentTypes = ref.watch(paymentTypesProvider);
    final paymentMethods = ref.watch(paymentMethodsProvider);
    final availableMonths = ref.watch(availableMonthsProvider);

    final hasActiveFilters = filterState.startDate != null ||
        filterState.endDate != null ||
        filterState.selectedMonth != null ||
        filterState.selectedPaymentType != null ||
        filterState.selectedPaymentMethod != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    if (hasActiveFilters)
                      TextButton.icon(
                        onPressed: () =>
                            ref.read(filterStateProvider.notifier).clearFilters(),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Clear'),
                      ),
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                      onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Expanded Filter Options
          if (_isExpanded)
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Filter
                  _FilterSection(
                    title: 'By Month',
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All Months',
                            selected: filterState.selectedMonth == null,
                            onSelected: (_) =>
                                ref.read(filterStateProvider.notifier).setMonth(null),
                          ),
                          ...availableMonths.map((month) {
                            final date = DateTime.parse('$month-01');
                            final label = DateFormat('MMM yyyy').format(date);
                            return _FilterChip(
                              label: label,
                              selected: filterState.selectedMonth == month,
                              onSelected: (_) => ref
                                  .read(filterStateProvider.notifier)
                                  .setMonth(month),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Date Range Filter
                  _FilterSection(
                    title: 'Custom Date Range',
                    child: Row(
                      children: [
                        Expanded(
                          child: _DateRangeButton(
                            label: 'From',
                            date: filterState.startDate,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    filterState.startDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                ref
                                    .read(filterStateProvider.notifier)
                                    .setDateRange(
                                      picked,
                                      filterState.endDate,
                                    );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateRangeButton(
                            label: 'To',
                            date: filterState.endDate,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    filterState.endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                ref
                                    .read(filterStateProvider.notifier)
                                    .setDateRange(
                                      filterState.startDate,
                                      picked,
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Payment Type Filter
                  _FilterSection(
                    title: 'Payment Type',
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All Types',
                            selected: filterState.selectedPaymentType == null,
                            onSelected: (_) => ref
                                .read(filterStateProvider.notifier)
                                .setPaymentType(null),
                          ),
                          ...paymentTypes.map((type) {
                            return _FilterChip(
                              label: type,
                              selected: filterState.selectedPaymentType == type,
                              onSelected: (_) => ref
                                  .read(filterStateProvider.notifier)
                                  .setPaymentType(type),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Payment Method Filter
                  _FilterSection(
                    title: 'Payment Method',
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All Methods',
                            selected: filterState.selectedPaymentMethod == null,
                            onSelected: (_) => ref
                                .read(filterStateProvider.notifier)
                                .setPaymentMethod(null),
                          ),
                          ...paymentMethods.map((method) {
                            return _FilterChip(
                              label: method,
                              selected: filterState.selectedPaymentMethod == method,
                              onSelected: (_) => ref
                                  .read(filterStateProvider.notifier)
                                  .setPaymentMethod(method),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Custom Filter Section Widget
class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({
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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// Custom Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: Colors.grey[100],
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: selected ? Theme.of(context).primaryColor : Colors.grey[700],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
    );
  }
}

// Date Range Button Widget
class _DateRangeButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateRangeButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: date != null
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: date != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: date != null
              ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
              : Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat('dd MMM').format(date!)
                      : 'Select',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: date != null ? Colors.black : Colors.grey[500],
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: date != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}