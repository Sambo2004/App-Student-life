import 'package:flutter/material.dart';

import '../data/student_store.dart';
import '../widgets/app_shell.dart';
import '../widgets/page_header.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  Future<void> _addExpense(BuildContext context) async {
    final title = TextEditingController();
    final amount = TextEditingController();
    final notes = TextEditingController();
    var category = 'Food';
    var paymentMethod = 'Cash';

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add expense'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        actionsOverflowDirection: VerticalDirection.down,
        actionsOverflowButtonSpacing: 8,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount (USD)'),
              ),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const ['Food', 'Transport', 'Study', 'Housing', 'Other']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) category = value;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: const ['Cash', 'Card', 'Transfer', 'Other']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) paymentMethod = value;
                },
              ),
              TextField(
                controller: notes,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(amount.text);
              if (value != null && value > 0) {
                StudentStore.instance.addExpense(
                  title.text,
                  value,
                  category: category,
                  paymentMethod: paymentMethod,
                  notes: notes.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editExpense(
    BuildContext context,
    StudentExpense expense,
  ) async {
    final title = TextEditingController(text: expense.title);
    final amount = TextEditingController(
      text: expense.amount.toStringAsFixed(2),
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount (USD)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(amount.text);
              if (title.text.trim().isEmpty || value == null || value <= 0) {
                return;
              }
              StudentStore.instance.updateExpense(
                expense,
                StudentExpense(
                  title.text.trim(),
                  value,
                  expense.date,
                  category: expense.category,
                  paymentMethod: expense.paymentMethod,
                  notes: expense.notes,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppShell(
    index: 3,
    child: AnimatedBuilder(
      animation: StudentStore.instance,
      builder: (context, _) {
        final store = StudentStore.instance;
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addExpense(context),
            icon: const Icon(Icons.add),
            label: const Text('Expense'),
          ),
          body: ListView(
            children: [
              const PageHeader(
                title: 'Expense tracker',
                subtitle: 'Keep your student budget clear.',
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'TOTAL SPENDING\nUSD ${store.totalExpenses.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...store.expenses.map(
                (expense) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                  title: Text(expense.title),
                  subtitle: Text(
                    '${expense.category} - ${expense.paymentMethod} - ${dateText(expense.date)}${expense.notes.isEmpty ? '' : '\n${expense.notes}'}',
                  ),
                  isThreeLine: expense.notes.isNotEmpty,
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Edit expense',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editExpense(context, expense),
                      ),
                      IconButton(
                        tooltip: 'Delete expense',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          StudentStore.instance.deleteExpense(expense);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Expense deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () => StudentStore.instance
                                    .restoreExpense(expense),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

String dateText(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
