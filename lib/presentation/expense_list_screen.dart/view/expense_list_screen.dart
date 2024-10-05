import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _addExpense() async {
    if (_formKey.currentState!.validate()) {
      String name = _expenseNameController.text.trim();
      String amount = _amountController.text.trim();

      await FirebaseFirestore.instance.collection('expenses').add({
        'name': name,
        'amount': double.parse(amount),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _expenseNameController.clear();
      _amountController.clear();

      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const Icon(null),
        title: const Text(
          "Expense Tracker",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 10.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _expenseNameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Expense Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Expense name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Amount is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('expenses')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }
                  if (snapshot.hasData) {
                    final expenses = snapshot.data!.docs;

                    double totalExpense = expenses.fold(0.0, (sum, doc) {
                      var expense = doc.data() as Map<String, dynamic>;
                      var amount = expense['amount'];
                      if (amount is String) {
                        amount = double.tryParse(amount) ?? 0.0;
                      } else if (amount is! double && amount is! int) {
                        amount = 0.0;
                      }
                      return sum + (amount as num);
                    });

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              var expense = expenses[index].data()
                                  as Map<String, dynamic>;
                              return Card(
                                elevation: 4, // Shadow effect
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  title: Text(
                                    expense['name'] ?? '',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp),
                                  ),
                                  subtitle:
                                      Text('Amount: ₹${expense['amount']}'),
                                  tileColor: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total ',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' ₹$totalExpense',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const Text("No expenses added");
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        backgroundColor: Colors.red[400],
        icon: const Icon(Icons.currency_rupee, color: Colors.white),
        label: const Text("Add Expense", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
