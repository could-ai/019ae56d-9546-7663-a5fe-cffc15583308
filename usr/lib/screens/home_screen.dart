import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock Data
  final List<Transaction> _userTransactions = [
    Transaction(
      id: 't1',
      title: 'Grocery Shopping',
      amount: 54.99,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.expense,
      category: 'Food',
    ),
    Transaction(
      id: 't2',
      title: 'Monthly Salary',
      amount: 3000.00,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.income,
      category: 'Salary',
    ),
  ];

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  double get _totalBalance {
    double income = _userTransactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
    double expense = _userTransactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
    return income - expense;
  }

  double get _totalIncome {
    return _userTransactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalExpense {
    return _userTransactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  void _addNewTransaction(Transaction tx) {
    setState(() {
      _userTransactions.insert(0, tx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return AddTransactionScreen(onAddTransaction: _addNewTransaction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${_totalBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _totalBalance >= 0 ? Colors.black : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text('Income', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Text(
                            '\$${_totalIncome.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.grey[300]),
                      Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.arrow_downward, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text('Expense', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Text(
                            '\$${_totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          
          // Recent Transactions Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: _userTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions added yet!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _userTransactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = _userTransactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: tx.type == TransactionType.income
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            child: Icon(
                              tx.type == TransactionType.income
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: tx.type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(
                            tx.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${tx.category} • ${DateFormat.yMMMd().format(tx.date)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${tx.type == TransactionType.income ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tx.type == TransactionType.income
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
                                onPressed: () => _deleteTransaction(tx.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
