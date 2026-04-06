import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';

// Preset categories with emojis
const _categories = [
  ('🍔', 'Food'),
  ('☕', 'Coffee'),
  ('🛍️', 'Shopping'),
  ('🚗', 'Transport'),
  ('🎮', 'Entertainment'),
  ('💊', 'Health'),
  ('🏠', 'Rent'),
  ('💸', 'Other'),
];

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  String _type = 'expense';
  String _selectedCategory = 'Food';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Text('add_transaction'.tr(),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Type selector
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                  value: 'income',
                  label: Text('income'.tr()),
                  icon: const Text('💰')),
              ButtonSegment(
                  value: 'expense',
                  label: Text('expenses'.tr()),
                  icon: const Text('💸')),
              ButtonSegment(
                  value: 'debt',
                  label: Text('debt'.tr()),
                  icon: const Text('😬')),
            ],
            selected: {_type},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return _type == 'income'
                      ? const Color(0xFF00FF7F).withValues(alpha: 0.2)
                      : const Color(0xFFFF3355).withValues(alpha: 0.2);
                }
                return null;
              }),
            ),
            onSelectionChanged: (Set<String> s) =>
                setState(() => _type = s.first),
          ),

          const SizedBox(height: 20),

          // Amount input
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'amount'.tr(),
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70),
            ),
          ),

          const SizedBox(height: 20),

          // Category chips
          Align(
            alignment: Alignment.centerLeft,
            child: Text('category'.tr(),
                style: const TextStyle(
                    color: Colors.white54, fontSize: 13)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final selected = _selectedCategory == cat.$2;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedCategory = cat.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF00FF7F).withValues(alpha: 0.15)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF00FF7F)
                          : Colors.white12,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    '${cat.$1} ${cat.$2}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected
                            ? const Color(0xFF00FF7F)
                            : Colors.white70),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final amount =
                    double.tryParse(_amountController.text) ?? 0.0;
                if (amount <= 0) return;

                final transaction = Transaction(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  amount: amount,
                  type: _type,
                  category: _selectedCategory,
                  date: DateTime.now(),
                );

                final budgetLimit = ref.read(settingsProvider);
                final summary = ref.read(summaryProvider);
                final expensesBefore = summary['expenses'] ?? 0.0;
                
                bool shouldAlert = false;
                if (budgetLimit != null && (_type == 'expense' || _type == 'debt')) {
                  if ((expensesBefore + amount) > budgetLimit) {
                    shouldAlert = true;
                  }
                }

                ref
                    .read(transactionsProvider.notifier)
                    .addTransaction(transaction);
                Navigator.pop(context, shouldAlert);
              },
              child: Text('save'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
